import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, writeFile, rm, symlink, stat, realpath } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import TOML from '@iarna/toml';
import { Configuration, jsonc } from './config.mjs';
import { SharedSetup, validateSetup, exportServer, importServer, replaceTomlServers } from './shared.mjs';
import { makeApp } from './index.mjs';
import { aiRoot, hookContexts, hookOutput } from '../../hooks/context.mjs';

async function fixture(t) {
  const home = await mkdtemp(path.join(tmpdir(), 'agent-hub-shared-')); const root = path.join(home, '.dotfiles');
  await mkdir(path.join(root, 'ai/config'), { recursive: true });
  const config = new Configuration({ home, root, data: path.join(home, '.local/share/agent-hub'), codex: {} }); await config.init();
  const shared = new SharedSetup(config);
  shared.tools = () => ['codex', 'claude', 'opencode', 'gemini', 'cursor', 'copilot', 'pi', 'droid'].map(id => ({ id, name: id, available: true, mcp: id !== 'droid', hooks: ['codex', 'claude', 'gemini', 'cursor', 'opencode', 'pi'].includes(id) }));
  t.after(() => rm(home, { recursive: true, force: true }));
  return { home: config.home, root: config.root, config, shared };
}
const setup = () => ({ servers: { local: { type: 'stdio', command: 'node', args: ['server.mjs'], enabled: true }, remote: { type: 'http', url: 'https://mcp.example.com/mcp', enabled: true } }, hooks: [{ id: 'audit', event: 'afterTool', command: '/usr/bin/true', enabled: true }] });
const save = async (shared, value) => shared.save({ value, revision: (await shared.source()).revision });

test('exports shared MCP and hook formats to all supported targets, including Cursor without its CLI', async t => {
  const f = await fixture(t); const value = setup();
  const result = await save(f.shared, value);
  assert.equal(result.path, path.join(f.root, 'ai/config/shared-setup.json'));
  assert.deepEqual(jsonc(await readFile(result.path, 'utf8')), value);
  for (const tool of ['codex', 'claude', 'opencode', 'gemini', 'cursor', 'copilot', 'pi']) {
    const native = await f.shared.native(tool);
    assert.deepEqual(native.servers.local, exportServer(tool, value.servers.local));
    assert.deepEqual(native.servers.remote, exportServer(tool, value.servers.remote));
    assert.equal(result.targets.find(target => target.id === tool).status, ['copilot', 'opencode', 'pi'].includes(tool) ? 'drift' : 'synced', JSON.stringify(result.targets.find(target => target.id === tool)));
  }
  const cursor = jsonc(await readFile(path.join(f.home, '.cursor/hooks.json'), 'utf8'));
  assert.equal(cursor.version, 1); assert.deepEqual(cursor.hooks.postToolUse, [{ command: '/usr/bin/true' }]);
  const gemini = jsonc(await readFile(path.join(f.home, '.gemini/settings.json'), 'utf8'));
  assert.ok(new RegExp(gemini.hooks.AfterTool[0].matcher).test('read_file'));
  assert.equal(result.targets.find(target => target.id === 'droid').status, 'unsupported');
  assert.equal((await stat(f.shared.file)).mode & 0o777, 0o600);
  const production = new SharedSetup(f.config);
  await mkdir(path.join(f.home, '.cursor'), { recursive: true }); assert.equal(production.tools().find(tool => tool.id === 'cursor').available, true);
});

test('updates, disables, and removes only owned entries; native JSON comments and unrelated fields survive', async t => {
  const f = await fixture(t); const file = path.join(f.home, '.gemini/settings.json'); await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, '{ // keep comment\n"private":"PRIVATE", "mcpServers":{"unrelated":{"command":"native"}},"hooks":{"AfterTool":[{"hooks":[{"type":"command","command":"native hook"}]}]}}');
  await save(f.shared, setup()); const value = setup(); value.servers.local.args = ['changed.mjs']; value.servers.remote.enabled = false; value.hooks = [];
  await save(f.shared, value);
  const raw = await readFile(file, 'utf8'); const actual = jsonc(raw);
  assert.ok(raw.includes('// keep comment')); assert.equal(actual.private, 'PRIVATE'); assert.equal(actual.mcpServers.unrelated.command, 'native');
  assert.equal(actual.mcpServers.remote, undefined); assert.deepEqual(actual.mcpServers.local.args, ['changed.mjs']);
  assert.deepEqual(actual.hooks.AfterTool, [{ hooks: [{ type: 'command', command: 'native hook' }] }]);
  const snapshot = await f.shared.snapshot(); assert.ok(!JSON.stringify(snapshot).includes('PRIVATE')); assert.ok(snapshot.targets.find(target => target.id === 'gemini').extra.includes('unrelated'));
  await save(f.shared, { servers: {}, hooks: [] }); assert.equal((await f.shared.native('cursor')).servers.local, undefined);
});

test('native conflicts block only the affected target; malformed settings never leak credentials', async t => {
  const f = await fixture(t); const cursor = path.join(f.home, '.cursor/mcp.json'); await mkdir(path.dirname(cursor), { recursive: true });
  await writeFile(cursor, '{"mcpServers":{"local":{"command":"keep-me"}}}');
  const bad = path.join(f.home, '.gemini/settings.json'); await mkdir(path.dirname(bad), { recursive: true }); await writeFile(bad, 'bad SECRET');
  const result = await save(f.shared, setup());
  assert.equal((await f.shared.native('cursor')).servers.local.command, 'keep-me');
  assert.equal((await f.shared.native('claude')).servers.local.command, 'node');
  assert.equal(result.targets.find(target => target.id === 'cursor').status, 'error');
  assert.ok(!JSON.stringify(result).includes('SECRET'));
});

test('native imports detect stale revisions, preserve source ownership, and reject lossy options', async t => {
  const f = await fixture(t); const native = await f.shared.native('claude'); await mkdir(path.dirname(native.file), { recursive: true });
  const server = { type: 'http', url: 'https://mcp.example.com/mcp' }; await writeFile(native.file, JSON.stringify({ private: 'secret', mcpServers: { imported: server } }));
  let state = await f.shared.snapshot(); const candidate = state.imports.find(item => item.tool === 'claude');
  await assert.rejects(f.shared.import({ ...candidate, revision: 'stale', sourceRevision: state.revision }), /Native server changed/);
  state = await f.shared.import({ ...candidate, sourceRevision: state.revision });
  assert.ok(state.value.servers.imported.enabled); assert.equal((await f.shared.native('cursor')).servers.imported.url, server.url);
  await assert.rejects(f.shared.save({ value: setup(), revision: 'stale' }), /Reload before saving/);
  assert.throws(() => importServer('codex', { command: 'node', startup_timeout_sec: 60 }), /Unsupported configuration field/);
  assert.throws(() => importServer('opencode', { type: 'local', command: 'node' }), /nonempty arrays/);
  assert.throws(() => importServer('opencode', { type: 'remote', url: server.url, oauth: false }), /OAuth disablement/);
});

test('TOML editing preserves other tables, quoted keys, values, and their comments', () => {
  const raw = '# heading\nmodel = "example"\n[mcp_servers.old]\ncommand = "old"\n["mcp_servers"."quoted-name".env]\nX = "1"\n[plugins.example]\nenabled = true # keep\n';
  const servers = { new: { command: 'node', args: ['server.mjs'] } }; const next = replaceTomlServers(raw, servers);
  assert.ok(next.includes('# heading')); assert.ok(next.includes('true # keep'));
  assert.deepEqual(TOML.parse(next), { model: 'example', mcp_servers: servers, plugins: { example: { enabled: true } } });
  assert.throws(() => replaceTomlServers('mcp_servers = { old = { command = "old" } }\n', servers), /Cannot safely edit/);
});

test('transaction failure rolls back all files; restart recovery preserves external changes', async t => {
  const f = await fixture(t); await save(f.shared, setup());
  const before = await readFile(f.shared.file, 'utf8'); const original = f.config.atomic.bind(f.config); let failed = false;
  f.config.atomic = async (file, content) => { if (!failed && file.endsWith('.cursor/mcp.json')) { failed = true; throw new Error('disk failure'); } return original(file, content); };
  const value = setup(); value.servers.local.command = 'updated';
  await assert.rejects(save(f.shared, value), /disk failure/);
  assert.equal((await f.shared.native('codex')).servers.local.command, 'node');
  // Source saves independently so a retry can apply the user's desired settings.
  assert.equal((await f.shared.source()).value.servers.local.command, 'updated');
  const file = f.shared.file; const change = { file, before, after: JSON.stringify(value) };
  await original(f.shared.journal, JSON.stringify({ changes: [change] })); await original(file, change.after);
  await f.shared.recover(); assert.equal(await readFile(file, 'utf8'), before);
  await original(f.shared.journal, JSON.stringify({ changes: [change] })); await original(file, 'external');
  await assert.rejects(f.shared.recover(), /configuration changed after interrupted sync/); assert.equal(await readFile(file, 'utf8'), 'external');
});

test('source edits reconcile automatically, symlink escapes fail, unsupported hooks remain visible', async t => {
  const f = await fixture(t); await save(f.shared, setup());
  const value = setup(); value.servers.local.command = 'next'; value.hooks.push({ id: 'finish', event: 'stop', command: '/usr/bin/true', enabled: true });
  await writeFile(f.shared.file, JSON.stringify(value)); const result = await f.shared.reconcile();
  assert.equal((await f.shared.native('cursor')).servers.local.command, 'next');
  assert.ok(result.targets.find(target => target.id === 'gemini').issues.some(issue => issue.includes('no equivalent')));
  const escape = path.join(f.home, 'outside.json'); await writeFile(escape, '{}'); const cursor = path.join(f.home, '.cursor/mcp.json'); await rm(cursor); await symlink(escape, cursor);
  await assert.rejects(f.shared.native('cursor'), /leaves its managed root/);
});

test('validation rejects malformed payloads and nonportable interpolation before writes', () => {
  for (const value of [null, {}, { servers: [], hooks: [] }, { servers: { bad: { type: 'http', url: 'file:///tmp/key', enabled: true } }, hooks: [] }, { servers: {}, hooks: [{ id: 'x', event: 'anything', command: 'true', enabled: true }] }]) assert.throws(() => validateSetup(value));
  const value = setup(); value.servers.local.env = { KEY: '${env:SECRET}' }; assert.throws(() => validateSetup(value), /not portable/);
});

test('first-time Cursor hook setup creates valid repository JSON', async t => {
  const f = await fixture(t); await f.shared.hookDocument('cursor');
  const document = await f.config.readDocument('hooks:cursor');
  assert.deepEqual(jsonc(document.content), { version: 1, hooks: {} });
  assert.equal(document.path, path.join(f.root, 'ai/hooks/cursor.json'));
});

test('shared policy hooks preserve content while agent opt-outs remove only the selected registration', async t => {
  const f = await fixture(t); const root = path.join(f.root, 'ai');
  for (const [relative, content] of [['skills/i-have-adhd/SKILL.md', '---\nname: i-have-adhd\ndescription: ADHD example\n---\nADHD instructions'], ['skills/ponytail/SKILL.md', '---\nname: ponytail\ndescription: Ponytail example\n---\nPonytail instructions'], ['skills/difit/SKILL.md', '---\nname: difit\ndescription: Human review\n---\nDifit instructions']]) {
    await mkdir(path.dirname(path.join(root, relative)), { recursive: true }); await writeFile(path.join(root, relative), content);
  }
  const value = { servers: {}, hooks: ['adhd', 'ponytail', 'difit'].map(id => ({ id, context: id, event: 'sessionStart', enabled: true, disabledAgents: [] })) };
  await save(f.shared, value);
  let cursor = jsonc(await readFile(path.join(f.home, '.cursor/hooks.json'), 'utf8'));
  assert.equal(cursor.hooks.sessionStart.length, 3);
  assert.ok(cursor.hooks.sessionStart.every(entry => entry.command.includes(path.join(root, 'hooks/context.mjs'))));
  assert.equal((await hookContexts(root, 'cursor')).length, 3);
  const output = await hookOutput(root, 'cursor', 'adhd', 'sessionStart');
  assert.ok(output.additional_context.includes('ADHD instructions')); assert.ok(!output.additional_context.includes('name: i-have-adhd'));
  const exposed = (await f.shared.snapshot()).contexts.adhd;
  assert.equal(exposed.content, output.additional_context);
  assert.equal(exposed.path, path.join(root, 'skills/i-have-adhd/SKILL.md'));
  assert.equal((await hookOutput(root, 'claude', 'adhd', 'SessionStart')).hookSpecificOutput.additionalContext, output.additional_context);
  value.hooks[2].disabledAgents = ['cursor']; await save(f.shared, value);
  cursor = jsonc(await readFile(path.join(f.home, '.cursor/hooks.json'), 'utf8'));
  assert.equal(cursor.hooks.sessionStart.length, 2);
  assert.deepEqual(await hookOutput(root, 'cursor', 'difit', 'sessionStart'), {});
  const contextDocument = await f.config.readDocument('hook-context:difit');
  await f.config.saveDocument({ ...contextDocument, content: '---\nname: difit\ndescription: Human review\n---\nUpdated Difit instructions' });
  assert.ok((await hookOutput(root, 'claude', 'difit', 'SessionStart')).hookSpecificOutput.additionalContext.includes('Updated Difit instructions'));
  assert.ok((await f.shared.snapshot()).contexts.difit.content.includes('Updated Difit instructions'));
  assert.equal((await hookContexts(root, 'claude')).length, 3);
  value.hooks[1].enabled = false; await save(f.shared, value);
  assert.equal((await hookContexts(root, 'cursor')).length, 1);
  assert.equal((await hookContexts(root, 'claude')).length, 2);
  assert.deepEqual((await f.shared.source()).value.hooks[2].disabledAgents, ['cursor']);
  const restarted = new SharedSetup(f.config); restarted.tools = f.shared.tools; await restarted.reconcile();
  assert.equal(jsonc(await readFile(path.join(f.home, '.cursor/hooks.json'), 'utf8')).hooks.sessionStart.length, 1);
  assert.throws(() => validateSetup({ servers: {}, hooks: [{ ...value.hooks[0], disabledAgents: ['unknown'] }] }), /known agent IDs/);
  assert.throws(() => validateSetup({ servers: {}, hooks: [{ context: 'adhd', event: 'sessionStart', enabled: true }] }), /unique id/);
});

test('OpenCode and Pi adapters inject the shared policies without replacing existing instructions', async () => {
  const expected = await hookContexts(aiRoot, 'opencode');
  const { default: plugin } = await import('../../plugins/opencode/shared-hooks/index.mjs');
  let handler; await plugin.setup({ session: { hook: async (name, callback) => { assert.equal(name, 'context'); handler = callback; } } });
  const system = [{ type: 'text', text: 'Keep this instruction' }]; await handler({ system });
  assert.equal(system[0].text, 'Keep this instruction'); assert.deepEqual(system.slice(1).map(part => part.text), expected);
  const { default: extension } = await import('../../hooks/pi-extension.ts');
  let before; extension({ on: (name, callback) => { assert.equal(name, 'before_agent_start'); before = callback; } });
  const contexts = await hookContexts(aiRoot, 'pi'); const result = await before({ systemPrompt: 'Existing system' });
  assert.equal(result?.systemPrompt, contexts.length ? 'Existing system\n\n' + contexts.join('\n\n') : undefined);
});

test('custom text and skill references share exact context, follow source edits, and honor agent opt-outs', async t => {
  const f = await fixture(t); const root = path.join(f.root, 'ai'); const file = path.join(root, 'skills/example/SKILL.md');
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, '---\nname: example\ndescription: Example\n---\nOriginal skill instructions');
  const value = { servers: {}, hooks: [
    { id: 'custom-text', text: '---\nKeep this exact text.\n${literal}', event: 'sessionStart', enabled: true, disabledAgents: [] },
    { id: 'custom-skill', skill: 'example', event: 'sessionStart', enabled: true, disabledAgents: ['cursor'] },
  ] };
  const state = await save(f.shared, value);
  assert.deepEqual(state.skills.map(skill => skill.name), ['example']);
  assert.ok(state.contexts['custom-text'].content.endsWith(value.hooks[0].text));
  assert.equal(state.contexts['custom-text'].documentId, undefined);
  assert.ok(state.contexts['custom-skill'].documentId);
  const cursor = await hookOutput(root, 'cursor', 'custom-text', 'sessionStart');
  assert.equal(cursor.additional_context, state.contexts['custom-text'].content);
  assert.deepEqual(await hookOutput(root, 'cursor', 'custom-skill', 'sessionStart'), {});
  const claude = await hookOutput(root, 'claude', 'custom-skill', 'SessionStart');
  assert.ok(claude.hookSpecificOutput.additionalContext.endsWith('Original skill instructions'));
  assert.ok(!claude.hookSpecificOutput.additionalContext.includes('description:'));
  await writeFile(file, '---\nname: example\ndescription: Example\n---\nUpdated skill instructions');
  assert.ok((await hookContexts(root, 'pi')).some(content => content.endsWith('Updated skill instructions')));
  const registration = jsonc(await readFile(path.join(f.home, '.cursor/hooks.json'), 'utf8'));
  assert.equal(registration.hooks.sessionStart.length, 1);
});

test('context sources reject ambiguity, invalid names, missing skills, and symlink escapes before saving', async t => {
  const f = await fixture(t); const hook = { id: 'custom', text: 'Instructions', event: 'sessionStart', enabled: true };
  for (const invalid of [{ ...hook, skill: 'example' }, { ...hook, text: '' }, { ...hook, event: 'beforeTool' }, { id: 'custom', skill: '../outside', event: 'sessionStart', enabled: true }]) assert.throws(() => validateSetup({ servers: {}, hooks: [invalid] }));
  const value = { servers: {}, hooks: [{ id: 'custom', skill: 'example', event: 'sessionStart', enabled: true }] };
  const before = (await f.shared.source()).revision;
  await assert.rejects(save(f.shared, value), /ENOENT/);
  assert.equal((await f.shared.source()).revision, before);
  const directory = path.join(f.root, 'ai/skills/example'); await mkdir(directory, { recursive: true });
  const outside = path.join(f.home, 'outside.md'); await writeFile(outside, 'Do not read this outside file');
  await symlink(outside, path.join(directory, 'SKILL.md'));
  await assert.rejects(save(f.shared, value), /resolve inside ai\/skills/);
  assert.equal((await f.shared.source()).revision, before);
});

test('skill sharing activates on creation and includes newly detected Cursor without library changes', async t => {
  const f = await fixture(t); const skill = path.join(f.root, 'ai/skills/example/SKILL.md');
  await mkdir(path.dirname(skill), { recursive: true }); await writeFile(skill, '---\nname: example\ndescription: Example\n---\n');
  f.config.codex = { catalogue: async () => ({ skills: [{ name: 'example', path: skill, enabled: true }], plugins: [], warnings: [] }), setLibrarySkills: async () => {} };
  const target = id => ({ target: id, path: path.join(f.home, `.${id}/skills`), source: path.join(f.config.data, 'skills', id) });
  f.config.syncTargets = async () => ['codex', 'claude', 'opencode'].map(target);
  await f.config.maintainSync({ activate: true }); const fingerprint = (await f.config.readState()).sync.fingerprint;
  f.config.syncTargets = async () => ['codex', 'claude', 'opencode', 'cursor'].map(target);
  await f.config.maintainSync();
  assert.equal((await f.config.readState()).sync.fingerprint, fingerprint);
  assert.equal(await realpath(path.join(target('cursor').path, 'example')), path.dirname(skill));
  await f.config.createSkill({ name: 'added', description: 'New shared skill', content: 'Instructions' });
  await f.config.maintainSync({ activate: true });
  assert.equal(await realpath(path.join(target('cursor').path, 'added')), path.join(f.root, 'ai/skills/added'));
});

test('shared HTTP API authenticates mutations, rejects stale saves, and exports to Cursor', async t => {
  const f = await fixture(t); const skill = path.join(f.root, 'ai/skills/example/SKILL.md');
  await mkdir(path.dirname(skill), { recursive: true }); await writeFile(skill, '---\nname: example\ndescription: Example\n---\n');
  await mkdir(path.join(f.home, '.cursor'));
  const codex = { catalogue: async () => ({ skills: [], plugins: [], warnings: [] }), setPlugin: async () => {}, close() {} };
  const app = await makeApp({ home: f.home, root: f.root, data: f.config.data, codex });
  await new Promise((resolve, reject) => { app.server.once('error', reject); app.server.listen(0, '127.0.0.1', resolve); });
  t.after(() => new Promise(resolve => app.server.close(resolve)));
  const base = `http://127.0.0.1:${app.server.address().port}`;
  const state = await fetch(base + '/api/shared').then(response => response.json());
  assert.ok(state.targets.find(target => target.id === 'cursor').available);
  const payload = { value: setup(), revision: state.revision };
  const post = (body, token = app.token) => fetch(base + '/api/shared/save', { method: 'POST', headers: { Origin: base, 'Content-Type': 'application/json', 'X-Agent-Hub-Token': token }, body: JSON.stringify(body) });
  assert.equal((await post(payload, '')).status, 403);
  const saved = await post(payload); assert.equal(saved.status, 200);
  assert.equal(jsonc(await readFile(path.join(f.home, '.cursor/mcp.json'), 'utf8')).mcpServers.local.command, 'node');
  assert.equal((await post(payload)).status, 400);
});
