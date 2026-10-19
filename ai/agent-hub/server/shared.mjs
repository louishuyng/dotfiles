import { readFile, realpath, rm, chmod } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';
import { isDeepStrictEqual as equal } from 'node:util';
import TOML from '@iarna/toml';
import { modify, applyEdits } from 'jsonc-parser';
import { TOOL_DEFINITIONS, executable, hash, jsonc } from './config.mjs';
import { CONTEXT_FILES, enabledFor, isContextHook, readContext } from '../../hooks/context.mjs';

const EMPTY = { servers: {}, hooks: [] };
const ADAPTERS = {
  codex: ['.codex/config.toml', ['mcp_servers']],
  claude: ['.claude.json', ['mcpServers']],
  opencode: ['.config/opencode/opencode.jsonc', ['mcp', 'servers']],
  gemini: ['.gemini/settings.json', ['mcpServers']],
  cursor: ['.cursor/mcp.json', ['mcpServers']],
  copilot: ['.copilot/mcp-config.json', ['mcpServers']],
  pi: ['.pi/agent/mcp.json', ['mcpServers']],
};
const EVENTS = {
  codex: { sessionStart: 'SessionStart', beforeTool: 'PreToolUse', afterTool: 'PostToolUse', stop: 'Stop' },
  claude: { sessionStart: 'SessionStart', beforeTool: 'PreToolUse', afterTool: 'PostToolUse', stop: 'Stop' },
  gemini: { sessionStart: 'SessionStart', beforeTool: 'BeforeTool', afterTool: 'AfterTool' },
  cursor: { sessionStart: 'sessionStart', beforeTool: 'preToolUse', afterTool: 'postToolUse', stop: 'stop' },
};
const POLICY_AGENTS = ['codex', 'claude', 'gemini', 'cursor', 'opencode', 'pi'];
const object = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);
const text = (value) => typeof value === 'string' && value.trim().length > 0 && !value.includes('\0');
const identifier = (value) => typeof value === 'string' && /^[a-zA-Z0-9][a-zA-Z0-9_-]{0,79}$/.test(value);
const stringify = (value) => JSON.stringify(value, null, 2) + '\n';
async function optional(file) { try { return await readFile(file, 'utf8'); } catch (error) { if (error.code === 'ENOENT') return null; throw error; } }
function keys(value, allowed) { if (Object.keys(value).some(key => !allowed.includes(key))) throw new Error('Unsupported configuration field. Keep native-only options in the native editor.'); }
function strings(value) { return object(value) && Object.entries(value).every(([key, item]) => text(key) && typeof item === 'string' && !item.includes('\0')); }

export function validateSetup(value) {
  if (!object(value)) throw new Error('Shared setup must be an object.');
  keys(value, ['servers', 'hooks']);
  if (!object(value.servers) || !Array.isArray(value.hooks)) throw new Error('Shared setup requires servers and hooks.');
  if (Buffer.byteLength(JSON.stringify(value)) > 2 * 1024 * 1024) throw new Error('Shared setup exceeds 2 MB.');
  for (const [name, server] of Object.entries(value.servers)) {
    if (!identifier(name) || !object(server)) throw new Error('Use a server name with letters, numbers, underscores, and hyphens.');
    keys(server, ['type', 'command', 'args', 'env', 'url', 'headers', 'enabled']);
    if (typeof server.enabled !== 'boolean') throw new Error('Each server requires boolean enabled.');
    if (server.type === 'stdio') {
      if (!text(server.command) || (server.args !== undefined && (!Array.isArray(server.args) || server.args.some(arg => typeof arg !== 'string' || arg.includes('\0'))))) throw new Error('Stdio servers require a command and optional string arguments.');
      if (server.env !== undefined && !strings(server.env)) throw new Error('Environment values must be strings.');
      if (server.url !== undefined || server.headers !== undefined) throw new Error('Stdio servers cannot have HTTP fields.');
    } else if (server.type === 'http') {
      let url; try { url = new URL(server.url); } catch {}
      if (!url || !['http:', 'https:'].includes(url.protocol) || url.username || url.password) throw new Error('HTTP servers require an absolute HTTP(S) URL without embedded credentials.');
      if (server.headers !== undefined && !strings(server.headers)) throw new Error('HTTP headers must be strings.');
      if (server.command !== undefined || server.args !== undefined || server.env !== undefined) throw new Error('HTTP servers cannot have process fields.');
    } else throw new Error('Server type must be stdio or http.');
    // Native interpolation syntaxes differ; silently copying one changes its meaning.
    if (/\$\{|\{env:/.test(JSON.stringify(server))) throw new Error('Native environment placeholders are not portable. Use native configuration for environment references.');
  }
  const names = new Set();
  for (const hook of value.hooks) {
    if (!object(hook)) throw new Error('Each hook must be an object.');
    keys(hook, ['id', 'event', 'command', 'context', 'text', 'skill', 'enabled', 'disabledAgents']);
    if (!identifier(hook.id) || names.has(hook.id) || typeof hook.enabled !== 'boolean') throw new Error('Hooks require a unique id and boolean enabled.');
    if (['command', 'context', 'text', 'skill'].filter(key => Object.hasOwn(hook, key)).length !== 1) throw new Error('Choose exactly one hook source: context text, skill reference, existing context, or command.');
    if (isContextHook(hook)) {
      if (hook.event !== 'sessionStart') throw new Error('Context hooks run at session start.');
      if (hook.context !== undefined && !Object.hasOwn(CONTEXT_FILES, hook.context)) throw new Error('Choose a known shared context.');
      if (hook.text !== undefined && !text(hook.text)) throw new Error('Context text must not be empty.');
      if (hook.skill !== undefined && (typeof hook.skill !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(hook.skill) || hook.skill.length > 80)) throw new Error('Choose a shared skill name.');
    } else if (!['sessionStart', 'beforeTool', 'afterTool', 'stop'].includes(hook.event) || !text(hook.command)) throw new Error('Commands require a supported event and nonempty command.');
    if (hook.disabledAgents !== undefined && (!Array.isArray(hook.disabledAgents) || hook.disabledAgents.some(tool => !TOOL_DEFINITIONS.some(definition => definition[0] === tool)) || new Set(hook.disabledAgents).size !== hook.disabledAgents.length)) throw new Error('Disabled agents must be unique known agent IDs.');
    names.add(hook.id);
  }
  return value;
}

export function exportServer(tool, server) {
  if (server.type === 'stdio') {
    const { command, args = [], env = {} } = server;
    if (tool === 'opencode') return { type: 'local', command: [command, ...args], environment: env };
    return { ...(tool === 'claude' ? { type: 'stdio' } : tool === 'copilot' ? { type: 'local', tools: ['*'] } : {}), command, args, env };
  }
  const { url, headers = {} } = server;
  if (tool === 'codex') return { url, http_headers: headers };
  if (tool === 'opencode') return { type: 'remote', url, headers, ...(Object.keys(headers).length ? { oauth: false } : {}) };
  if (tool === 'gemini') return { httpUrl: url, headers };
  return { ...(tool === 'claude' || tool === 'copilot' ? { type: 'http' } : {}), url, headers, ...(tool === 'copilot' ? { tools: ['*'] } : {}) };
}

export function importServer(tool, native) {
  if (!object(native)) throw new Error('Invalid native server.');
  if (native.enabled !== undefined && typeof native.enabled !== 'boolean' || native.disabled !== undefined && typeof native.disabled !== 'boolean') throw new Error('Native enablement must be boolean.');
  const stdio = !!native.command;
  const allowed = stdio ? ['type', 'command', 'args', 'env', 'environment', 'enabled', 'disabled', 'tools'] : ['type', 'url', 'httpUrl', 'headers', 'http_headers', 'enabled', 'disabled', 'tools', 'oauth'];
  keys(native, allowed);
  if (native.tools && !equal(native.tools, ['*'])) throw new Error('Native tool filters cannot be shared safely.');
  if (native.oauth !== undefined && native.oauth !== false) throw new Error('Native OAuth options cannot be shared safely.');
  if (native.oauth === false && !Object.keys(native.headers || {}).length) throw new Error('Native OAuth disablement without static headers cannot be shared safely.');
  if (native.type && !(stdio ? ['local', 'stdio'] : ['remote', 'http']).includes(native.type)) throw new Error('Native transport is not supported.');
  if (stdio && tool === 'opencode' && (!Array.isArray(native.command) || !native.command.length)) throw new Error('OpenCode commands must be nonempty arrays.');
  const server = stdio
    ? { type: 'stdio', command: tool === 'opencode' ? native.command[0] : native.command, args: tool === 'opencode' ? native.command.slice(1) : native.args || [], env: native.environment || native.env || {}, enabled: native.enabled !== false && native.disabled !== true }
    : { type: 'http', url: native.httpUrl || native.url, headers: native.http_headers || native.headers || {}, enabled: native.enabled !== false && native.disabled !== true };
  validateSetup({ servers: { imported: server }, hooks: [] });
  return server;
}

function hookEntry(tool, hook, root) {
  const quote = value => "'" + value.replaceAll("'", "'\\''") + "'";
  const text = isContextHook(hook) ? [process.execPath, path.join(root, 'ai/hooks/context.mjs'), tool, hook.id, EVENTS[tool][hook.event]].map(quote).join(' ') : hook.command;
  const command = { type: 'command', command: text };
  return tool === 'cursor' ? { command: text } : { ...(['stop', 'sessionStart'].includes(hook.event) ? {} : { matcher: tool === 'gemini' ? '.*' : '*' }), hooks: [command] };
}
function at(value, parts) { for (const part of parts) { if (!object(value)) throw new Error('Native configuration section must be an object.'); value = value[part] ?? {}; } if (!object(value)) throw new Error('Native configuration section must be an object.'); return value; }
function edit(raw, parts, value) { return applyEdits(raw || '{}', modify(raw || '{}', parts, value, { formattingOptions: { insertSpaces: true, tabSize: 2 } })); }

export class SharedSetup {
  constructor(config) { this.config = config; this.file = path.join(config.root, 'ai/config/shared-setup.json'); this.receipt = path.join(config.data, 'shared-receipt.json'); this.journal = path.join(config.data, 'shared-pending.json'); }
  async source() {
    const parent = await realpath(path.dirname(this.file));
    if (parent !== path.dirname(this.file) || existsSync(this.file) && await realpath(this.file) !== this.file) throw new Error('Shared source must be a real file inside dotfiles/ai/config.');
    const raw = await optional(this.file); return { value: validateSetup(raw === null ? structuredClone(EMPTY) : jsonc(raw)), revision: hash(raw || '') };
  }
  tools() { return TOOL_DEFINITIONS.map(([id, name, , , command, directory]) => ({ id, name, available: !!command && !!executable(command) || existsSync(path.join(this.config.home, directory)), mcp: !!ADAPTERS[id], hooks: POLICY_AGENTS.includes(id), commandHooks: !!EVENTS[id] })); }
  async hookDocument(tool) {
    const relative = { codex: '.codex/hooks.json', claude: '.claude/settings.json', gemini: '.gemini/settings.json', cursor: '.cursor/hooks.json' }[tool];
    this.config.document(`hooks:${tool}`, 'Lifecycle hooks', tool, path.join(this.config.home, relative), 'hook', { format: 'json', ...(['claude', 'gemini'].includes(tool) ? { projection: ['hooks'] } : {}) });
    return this.config.resolveDocument(`hooks:${tool}`);
  }
  async target(relative) {
    const file = path.resolve(this.config.home, relative);
    let current = file; const missing = [];
    for (;;) {
      try { current = path.join(await realpath(current), ...missing.reverse()); break; }
      catch (error) { if (error.code !== 'ENOENT') throw error; missing.push(path.basename(current)); current = path.dirname(current); }
    }
    const roots = [path.join(this.config.home, path.dirname(relative)), path.join(this.config.root, 'ai'), path.join(this.config.root, 'opencode'), path.join(this.config.root, 'pi')];
    // Claude's mixed private settings live directly in the home directory.
    if (relative === '.claude.json' ? current !== file : !roots.some(root => current.startsWith(root + path.sep))) throw new Error('Configuration symlink leaves its managed root.');
    return current;
  }
  async native(tool) {
    const [relative, section] = ADAPTERS[tool]; const file = await this.target(relative); const raw = await optional(file);
    let value; try { value = tool === 'codex' ? TOML.parse(raw || '') : jsonc(raw || '{}'); } catch { throw new Error('Native configuration has invalid syntax. Repair it before syncing.'); }
    return { file, raw, value, section, servers: at(value, section) };
  }
  async snapshot() {
    const source = await this.source(); const receipt = jsonc(await optional(this.receipt) || '{}'); const targets = []; const imports = [];
    for (const tool of this.tools()) {
      const status = { ...tool, status: !tool.available ? 'not-installed' : !tool.mcp ? 'unsupported' : 'synced', issues: [], extra: [], matched: 0 };
      if (tool.available && tool.mcp) try {
        const native = await this.native(tool.id);
        for (const [name, value] of Object.entries(native.servers)) {
          if (!Object.hasOwn(source.value.servers, name)) {
            status.extra.push(name);
            try { importServer(tool.id, value); imports.push({ tool: tool.id, name, revision: hash(JSON.stringify(value)) }); }
            catch { status.issues.push(`${name}: native-only options require manual setup`); }
          }
        }
        const planned = await this.plan(tool.id, source.value, receipt[tool.id] || {});
        status.matched = planned.matched;
        status.issues.push(...planned.issues);
        if (planned.changes.length || status.extra.length || status.issues.length) status.status = 'drift';
      } catch (error) { status.status = 'error'; status.issues.push(error.message); }
      for (const hook of source.value.hooks.filter(hook => tool.available && enabledFor(hook, tool.id))) {
        if (isContextHook(hook) ? !POLICY_AGENTS.includes(tool.id) : !EVENTS[tool.id]?.[hook.event]) status.issues.push(`${hook.id}: ${hook.event} has no equivalent native event`);
      }
      if (tool.available && POLICY_AGENTS.includes(tool.id) && !EVENTS[tool.id] && source.value.hooks.some(hook => isContextHook(hook) && enabledFor(hook, tool.id))) {
        const issue = await this.policyAdapterIssue(tool.id); if (issue) status.issues.push(issue);
      }
      if (status.status === 'synced' && status.issues.length) status.status = 'drift';
      targets.push(status);
    }
    const contexts = {};
    for (const hook of source.value.hooks.filter(isContextHook)) {
      try {
        const context = await readContext(path.join(this.config.root, 'ai'), hook);
        const documentId = hook.text === undefined ? `hook-context:${hook.id}` : undefined;
        if (documentId) this.config.document(documentId, `${hook.id} hook context`, 'shared', context.path, 'hook-source', {format:'skill'});
        contexts[hook.id] = { ...context, documentId };
      } catch { contexts[hook.id] = { error: 'Context source could not be read. Check the selected skill or source file.' }; }
    }
    let skills = []; try { skills = (await this.config.library()).skills.map(({name, description}) => ({name, description})); } catch (error) { if (error.code !== 'ENOENT') throw error; }
    return { ...source, path: this.file, targets, imports, contexts, skills, pending: (await optional(this.journal)) !== null };
  }
  async plan(tool, setup, previous) {
    const native = await this.native(tool); const servers = structuredClone(native.servers); const issues = []; const changes = []; const owned = {}; let matched = 0;
    for (const name of Object.keys(previous.servers || {})) if (!setup.servers[name]?.enabled) {
      if (Object.hasOwn(servers, name) && !equal(servers[name], previous.servers[name])) throw new Error(`${name}: managed server changed outside Agent Hub. Resolve it before removal.`);
      delete servers[name];
    }
    for (const [name, server] of Object.entries(setup.servers)) {
      if (!server.enabled) {
        if (Object.hasOwn(servers, name) && !Object.hasOwn(previous.servers || {}, name)) issues.push(`${name}: disabled shared server still exists in native settings`);
        continue;
      }
      const wanted = exportServer(tool, server);
      if (Object.hasOwn(servers, name) && !Object.hasOwn(previous.servers || {}, name)) {
        let imported; try { imported = importServer(tool, servers[name]); } catch {}
        if (!equal(imported, importServer(tool, wanted))) throw new Error(`${name}: conflicting native server. Import or rename it before sync.`);
      }
      if (equal(servers[name], wanted)) matched++;
      Object.defineProperty(servers, name, { value: wanted, writable: true, enumerable: true, configurable: true });
      Object.defineProperty(owned, name, { value: wanted, enumerable: true });
    }
    if (!equal(native.servers, servers)) {
      let next;
      if (tool === 'codex') {
        // Preserve unrelated TOML and comments, including tables after the MCP section.
        next = replaceTomlServers(native.raw || '', servers);
      } else next = edit(native.raw, native.section, servers);
      changes.push({ file: native.file, before: native.raw, after: next });
    }
    const hooks = {};
    if (EVENTS[tool] && (setup.hooks.length || Object.keys(previous.hooks || {}).length)) {
      const { doc, target } = await this.hookDocument(tool);
      const raw = await optional(target); const value = jsonc(raw || '{}'); const events = doc.projection ? at(value, doc.projection) : value.hooks || {};
      if (!object(events)) throw new Error('Native hooks must be an event object.');
      const next = structuredClone(events);
      for (const [event, entries] of Object.entries(previous.hooks || {})) {
        if (!Array.isArray(next[event] || [])) throw new Error('Native hook event must contain an array.');
        for (const entry of entries) { const index = (next[event] || []).findIndex(item => equal(item, entry)); if (index >= 0) next[event].splice(index, 1); }
      }
      for (const hook of setup.hooks.filter(hook => enabledFor(hook, tool))) {
        const event = EVENTS[tool][hook.event]; if (!event) continue;
        if (!Array.isArray(next[event] || [])) throw new Error('Native hook event must contain an array.');
        const entry = hookEntry(tool, hook, this.config.root); next[event] ||= []; next[event].push(entry); (hooks[event] ||= []).push(entry);
      }
      const projected = doc.projection ? edit(raw, doc.projection, next) : edit(raw, ['hooks'], next);
      const after = tool === 'cursor' ? edit(projected, ['version'], 1) : projected;
      if (after !== raw) {
        const same = changes.find(change => change.file === target);
        if (same) same.after = edit(same.after, doc.projection || ['hooks'], next);
        else changes.push({ file: target, before: raw, after });
      }
      const sourceRaw = await optional(doc.sourcePath);
      const sourceAfter = doc.projection ? stringify(next) : after;
      if (doc.sourcePath !== target && sourceAfter !== sourceRaw) changes.push({ file: doc.sourcePath, before: sourceRaw, after: sourceAfter });
    }
    return { changes, receipt: { servers: owned, hooks }, issues, matched };
  }
  async save({ value, revision }) {
    validateSetup(value); const current = await this.source();
    if (current.revision !== revision) throw new Error('Shared setup changed. Reload before saving.');
    for (const hook of value.hooks.filter(isContextHook)) await readContext(path.join(this.config.root, 'ai'), hook);
    await this.transaction([{ file: this.file, before: await optional(this.file), after: stringify(value) }]);
    await chmod(this.file, 0o600);
    return this.reconcile();
  }
  async policyAdapterIssue(tool) {
    try {
      if (tool === 'opencode') {
        const native = await this.native(tool);
        const wanted = path.join(this.config.root, 'ai/plugins/opencode/shared-hooks');
        return native.value.plugins?.some(plugin => (typeof plugin === 'string' ? plugin : plugin.package) === wanted) ? null : 'Shared context plugin is not registered. Restart Agent Hub to apply repository configuration.';
      }
      const file = await this.target('.pi/agent/settings.json'); const native = jsonc(await optional(file) || '{}');
      const wanted = path.join(this.config.root, 'ai/hooks/pi-extension.ts');
      return native.extensions?.includes(wanted) ? null : 'Shared context extension is not registered. Restart Agent Hub to apply repository configuration.';
    } catch { return 'Shared context adapter could not be checked.'; }
  }
  async import({ tool, name, revision, sourceRevision }) {
    if (!Object.hasOwn(ADAPTERS, tool) || !identifier(name)) throw new Error('Unknown server import.');
    const source = await this.source(); if (source.revision !== sourceRevision) throw new Error('Shared setup changed. Reload before importing.');
    if (Object.hasOwn(source.value.servers, name)) throw new Error('A shared server already has this name. Rename one before importing.');
    const native = await this.native(tool); const server = native.servers[name];
    if (!server || hash(JSON.stringify(server)) !== revision) throw new Error('Native server changed. Reload before importing.');
    Object.defineProperty(source.value.servers, name, { value: importServer(tool, server), enumerable: true });
    return this.save({ value: source.value, revision: source.revision });
  }
  async reconcile() {
    await this.recover(); if (!existsSync(this.file)) return this.snapshot();
    const { value } = await this.source(); const receiptRaw = await optional(this.receipt); const receipt = jsonc(receiptRaw || '{}');
    const changes = [];
    for (const tool of this.tools().filter(tool => tool.available && tool.mcp)) {
      try { const planned = await this.plan(tool.id, value, receipt[tool.id] || {}); changes.push(...planned.changes); receipt[tool.id] = planned.receipt; }
      catch { /* A broken target must not prevent other agents from receiving updates. */ }
    }
    if (!equal(jsonc(receiptRaw || '{}'), receipt)) changes.push({ file: this.receipt, before: receiptRaw, after: stringify(receipt) });
    if (changes.length) await this.transaction(changes);
    if (changes.length) this.config.catalogueTime = 0;
    return this.snapshot();
  }
  async transaction(changes) {
    if (await optional(this.journal)) throw new Error('An interrupted shared sync needs recovery before saving.');
    const journal = stringify({ changes });
    await this.config.atomic(path.join(this.config.data, 'shared-backups', `${Date.now()}-${randomUUID()}.json`), journal);
    await this.config.atomic(this.journal, journal);
    try {
      for (const change of changes) {
        if (await optional(change.file) !== change.before) throw new Error('Configuration changed during sync. Refresh and retry.');
        await this.config.atomic(change.file, change.after);
      }
      await rm(this.journal);
    } catch (error) { await this.recover(); throw error; }
  }
  async recover() {
    const raw = await optional(this.journal); if (!raw) return;
    const { changes } = jsonc(raw);
    const allowed = new Set([this.file, this.receipt]);
    for (const [tool, [relative]] of Object.entries(ADAPTERS)) {
      allowed.add(await this.target(relative));
      if (EVENTS[tool]) { const { doc, target } = await this.hookDocument(tool); allowed.add(target); allowed.add(doc.sourcePath); }
    }
    for (const change of changes) {
      if (!allowed.has(change.file)) throw new Error('Invalid shared sync recovery target.');
      const current = await optional(change.file);
      if (current !== change.before && current !== change.after) throw new Error('Recovery stopped: a configuration changed after interrupted sync. Preserve the private journal and repair it manually.');
    }
    for (const change of [...changes].reverse()) {
      if (change.before === null) await rm(change.file, { force: true }); else await this.config.atomic(change.file, change.before);
    }
    await rm(this.journal);
  }
}

export function replaceTomlServers(raw, servers) {
  const lines = raw.split(/(?<=\n)/); const kept = []; let mcp = false;
  for (const line of lines) {
    if (/^\s*\[/.test(line)) {
      const header = line.trim().replace(/\s+#.*$/, '');
      // Parsing the header recognizes quoted keys without matching similarly named tables.
      let table; try { table = TOML.parse(header + '\n'); } catch { table = {}; }
      mcp = Object.keys(table).length === 1 && Object.hasOwn(table, 'mcp_servers');
    }
    if (!mcp) kept.push(line);
  }
  const result = kept.join('').trimEnd() + '\n\n' + TOML.stringify({ mcp_servers: servers });
  const expected = TOML.parse(raw || ''); expected.mcp_servers = servers;
  let parsed; try { parsed = TOML.parse(result); } catch {}
  if (!equal(parsed, expected)) throw new Error('Cannot safely edit this TOML layout. Move inline MCP settings into [mcp_servers] tables first.');
  return result;
}
