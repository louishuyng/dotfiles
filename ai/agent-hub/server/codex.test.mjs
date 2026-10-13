import assert from 'node:assert/strict';
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { CodexClient } from './codex.mjs';

async function fixture(t, config = '') {
  const home = await mkdtemp(join(tmpdir(), 'agent-hub-codex-'));
  await mkdir(join(home, '.codex'));
  await writeFile(join(home, '.codex', 'config.toml'), config);
  const executable = join(home, 'codex-mock.mjs');
  await writeFile(executable, `#!${process.execPath}
import readline from 'node:readline';
const hydrated = new Set();
const methods = [];
readline.createInterface({input:process.stdin}).on('line', line => {
  const request = JSON.parse(line);
  if (!request.id) return;
  methods.push(request.method);
  let result;
  let error;
  switch (request.method) {
    case 'initialize': result = {}; break;
    case 'plugin/installed':
      result = {marketplaces:[{name:'remote',path:null,plugins:['one','two'].map(name =>
        ({id:name+'@remote',name,installed:true,enabled:true,source:{type:'remote'}}))}]};
      break;
    case 'plugin/read':
      hydrated.add(request.params.pluginName);
      result = {plugin:{summary:{enabled:false}}};
      break;
    case 'skills/list':
      if (!hydrated.has('two')) { process.exit(6); return; }
      result = {data:[{skills:['one','two'].map(name =>
        ({name:name+':skill',path:'/'+name+'/SKILL.md',enabled:true,pluginId:name+'@remote'}))}]};
      break;
    case 'config/value/write': result = {keyPath:request.params.keyPath,value:request.params.value}; break;
    case 'config/batchWrite': result = request.params; break;
    case 'skills/config/write': result = {effectiveEnabled:request.params.enabled}; break;
    case 'test/methods': result = methods; break;
    default: error = {code:-32601,message:'unsupported method'};
  }
  setTimeout(() => process.stdout.write(JSON.stringify({id:request.id,result,error})+'\\n'), request.id % 2 ? 10 : 0);
});
`, { mode: 0o700 });
  const client = new CodexClient({ home, cwd: home, executable });
  t.after(async () => { client.close(); await rm(home, { recursive: true, force: true }); });
  return { client, home };
}

test('hydrates remote skills and preserves backend enabled state despite plugin/read defaults', async (t) => {
  const { client } = await fixture(t);
  const result = await client.catalogue();
  assert.deepEqual(result.skills.map((skill) => skill.enabled), [true, true]);
  assert.deepEqual(result.plugins.map((plugin) => [plugin.id, plugin.enabled, plugin.marketplaceName]), [
    ['one@remote', true, 'remote'], ['two@remote', true, 'remote'],
  ]);
  assert.deepEqual(result.warnings, []);
});

test('explicit local plugin override disables owning skills', async (t) => {
  const { client } = await fixture(t, '[plugins."one@remote"]\nenabled = false\n');
  const result = await client.catalogue();
  assert.deepEqual(result.skills.map((skill) => skill.enabled), [false, true]);
  assert.equal(result.plugins[0].enabled, false);
});

test('plugins-only inventory preserves overrides without hydrating or listing skills', async (t) => {
  const { client } = await fixture(t, '[plugins."one@remote"]\nenabled = false\n');
  const result = await client.catalogue({ includeSkills: false });
  assert.deepEqual(result.skills, []);
  assert.deepEqual(result.plugins.map((plugin) => plugin.enabled), [false, true]);
  assert.deepEqual(result.warnings, []);
  assert.deepEqual(await client.call('test/methods', {}), ['initialize', 'plugin/installed', 'test/methods']);
});

test('library preferences replace submitted paths and preserve unrelated skill preferences', async (t) => {
  const { client } = await fixture(t, `
[plugins."one@remote"]
enabled = true
[hooks]
token = "private-fixture"
[[skills.config]]
path = "/remote/SKILL.md"
enabled = false
[[skills.config]]
name = "unrelated"
enabled = false
[[skills.config]]
path = "/library/archify/SKILL.md"
enabled = false
`);
  assert.deepEqual(await client.setLibrarySkills([
    { path: '/library/archify/SKILL.md', enabled: true },
    { path: '/library/caveman/SKILL.md', enabled: false },
  ]), {
    edits: [{ keyPath: 'skills.config', mergeStrategy: 'replace', value: [
      { path: '/remote/SKILL.md', enabled: false },
      { name: 'unrelated', enabled: false },
      { path: '/library/archify/SKILL.md', enabled: true },
      { path: '/library/caveman/SKILL.md', enabled: false },
    ] }],
  });
  assert.equal(client.process, null);
  assert.deepEqual(await client.setLibrarySkills([]), {
    edits: [{ keyPath: 'skills.config', mergeStrategy: 'replace', value: [
      { path: '/remote/SKILL.md', enabled: false },
      { name: 'unrelated', enabled: false },
      { path: '/library/archify/SKILL.md', enabled: false },
    ] }],
  });
});

test('library preferences reject invalid input and malformed config without leaking config contents', async (t) => {
  const { client } = await fixture(t, 'secret = "private-fixture"\nbroken = ??');
  for (const skills of [null, [{ path: 'relative/SKILL.md', enabled: true }],
    [{ path: '/library/README.md', enabled: true }], [{ path: '/library/SKILL.md', enabled: 'true' }],
    [{ path: '/library/SKILL.md', enabled: true }, { path: '/library/SKILL.md', enabled: false }]]) {
    await assert.rejects(client.setLibrarySkills(skills), /Library skill/);
  }
  await assert.rejects(client.setLibrarySkills([{ path: '/library/SKILL.md', enabled: true }]), (error) => {
    assert.match(error.message, /could not be read or parsed/);
    assert.doesNotMatch(error.message, /private-fixture/);
    return true;
  });
  assert.equal(client.process, null);
  const malformed = await fixture(t, '[skills]\nconfig = "invalid"\n');
  await assert.rejects(malformed.client.setLibrarySkills([]), /must be a list/);
});

test('writes supported selectors, reconnects, and rejects invalid input and RPC errors', async (t) => {
  const { client } = await fixture(t);
  assert.deepEqual(await client.setPlugin('one@remote', false), {
    keyPath: 'plugins."one@remote".enabled', value: false,
  });
  assert.deepEqual(await client.setSkill('/one/SKILL.md', false), { effectiveEnabled: false });
  await assert.rejects(client.setPlugin('invalid', true), /catalogue ID/);
  await assert.rejects(client.setSkill('../escape', false), /absolute path/);
  await assert.rejects(client.call('unsupported', {}), /unsupported method/);
});

test('missing executable reports a clear startup error', async (t) => {
  const { home } = await fixture(t);
  const client = new CodexClient({ home, cwd: home, executable: join(home, 'missing') });
  t.after(() => client.close());
  await assert.rejects(client.catalogue(), /executable was not found/);
});
