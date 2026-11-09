import test from 'node:test';
import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, mkdir, readdir, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { promisify } from 'node:util';
import { Vendors, validRef } from './vendor.mjs';

const git = (...args) => promisify(execFile)('git', args).then(result => result.stdout);

async function write(root, files) {
  for (const [relative, content] of Object.entries(files)) {
    await mkdir(path.dirname(path.join(root, relative)), { recursive: true });
    await writeFile(path.join(root, relative), content);
  }
}

async function fixture(t, { native = {}, calls = [] } = {}) {
  const home = await mkdtemp(path.join(tmpdir(), 'agent-hub-vendor-'));
  t.after(() => rm(home, { recursive: true, force: true }));
  const upstream = path.join(home, 'upstream'); const root = path.join(home, '.dotfiles'); const data = path.join(home, 'data');
  await write(upstream, { 'plugin.json': '{"version":"2.0.0"}', 'skills/a/SKILL.md': 'new a', 'skills/b/SKILL.md': 'b', 'agents/x.md': 'x', 'docs/guide.md': 'guide', 'docs/assets/logo.svg': '<svg/>', 'LICENSE': 'license', 'README.md': 'not vendored' });
  await git('-C', upstream, 'init', '--quiet', '-b', 'main');
  await git('-C', upstream, '-c', 'user.name=t', '-c', 'user.email=t@t', 'add', '.');
  await git('-C', upstream, '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '--quiet', '-m', 'init');
  const manifest = { name: 'demo', repo: upstream, ref: 'main', commit: 'old', version: '1.0.0', include: ['skills', 'agents', 'docs', 'LICENSE'], exclude: ['docs/assets'], skill: 'demo', native };
  await write(path.join(root, 'ai/vendor/demo'), { 'vendor.json': JSON.stringify(manifest), 'skills/a/SKILL.md': 'old a', 'skills/gone/SKILL.md': 'gone', 'agents/x.md': 'x', 'docs/guide.md': 'guide', 'LICENSE': 'license' });
  await mkdir(data, { recursive: true });
  const run = async (command, args) => {
    if (command === 'git') return git(...args);
    calls.push([command, ...args]);
    if (command === 'grok' && args.includes('list')) return '[]';
    return '';
  };
  return { home, root, upstream, vendors: new Vendors({ root, home, data, run }), dir: path.join(root, 'ai/vendor/demo') };
}

test('refs reject option-like and traversal values', () => {
  for (const ref of ['main', 'v0.1.1', 'release/2026', 'e9e1f06aa4e26e95cd4ed37210a0632202c429e9']) assert.ok(validRef(ref), ref);
  for (const ref of ['-c', '--upload-pack=x', 'a..b', 'a b', '', 'x'.repeat(129), undefined]) assert.ok(!validRef(ref), String(ref));
});

test('preview lists vendored changes and apply swaps the folder atomically', async t => {
  const f = await fixture(t);
  const commit = (await git('-C', f.upstream, 'rev-parse', 'HEAD')).trim();
  const plan = await f.vendors.preview({ name: 'demo' });
  assert.equal(plan.commit, commit); assert.equal(plan.version, '2.0.0'); assert.equal(plan.from.version, '1.0.0');
  assert.deepEqual(plan.changes, [
    { path: 'skills/a/SKILL.md', status: 'changed' },
    { path: 'skills/b/SKILL.md', status: 'added' },
    { path: 'skills/gone/SKILL.md', status: 'removed' },
  ]);
  await assert.rejects(f.vendors.apply({ name: 'demo', id: 'stale' }), /expired/);
  await f.vendors.apply({ name: 'demo', id: plan.id });
  assert.equal(await readFile(path.join(f.dir, 'skills/a/SKILL.md'), 'utf8'), 'new a');
  await assert.rejects(readFile(path.join(f.dir, 'skills/gone/SKILL.md')));
  await assert.rejects(readFile(path.join(f.dir, 'docs/assets/logo.svg')));
  await assert.rejects(readFile(path.join(f.dir, 'README.md')));
  const saved = JSON.parse(await readFile(path.join(f.dir, 'vendor.json'), 'utf8'));
  assert.equal(saved.commit, commit); assert.equal(saved.ref, 'main'); assert.equal(saved.version, '2.0.0'); assert.deepEqual(saved.exclude, ['docs/assets']);
  assert.deepEqual(await readdir(path.join(f.root, 'ai/vendor')), ['demo']);
  await assert.rejects(f.vendors.apply({ name: 'demo', id: plan.id }), /expired/);
});

test('preview refuses unknown refs and missing upstream folders without touching the vendor', async t => {
  const f = await fixture(t);
  await assert.rejects(f.vendors.preview({ name: 'demo', ref: 'nope' }), /no ref named nope/);
  await assert.rejects(f.vendors.preview({ name: 'demo', ref: '--upload-pack=x' }), /branch, tag, or commit/);
  await assert.rejects(f.vendors.preview({ name: '../demo' }), /Choose a vendored plugin/);
  await git('-C', f.upstream, 'rm', '--quiet', '-r', 'agents');
  await git('-C', f.upstream, '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '--quiet', '-m', 'drop agents');
  await assert.rejects(f.vendors.preview({ name: 'demo' }), /no longer has agents/);
  assert.equal(await readFile(path.join(f.dir, 'skills/a/SKILL.md'), 'utf8'), 'old a');
});

test('preview refuses upstream symlinks', async t => {
  const f = await fixture(t);
  await symlink(path.join(f.home, 'secret'), path.join(f.upstream, 'skills/b/link.md'));
  await git('-C', f.upstream, 'add', '.');
  await git('-C', f.upstream, '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '--quiet', '-m', 'link');
  await assert.rejects(f.vendors.preview({ name: 'demo' }), /symlink at skills\/b\/link.md/);
  assert.equal(await readFile(path.join(f.dir, 'skills/a/SKILL.md'), 'utf8'), 'old a');
});

test('check records the upstream commit for the pinned ref', async t => {
  const f = await fixture(t);
  const latest = await f.vendors.check('demo');
  assert.equal(latest.commit, (await git('-C', f.upstream, 'rev-parse', 'HEAD')).trim());
  assert.equal((await f.vendors.list()).vendors[0].latest.commit, latest.commit);
});

test('native sync updates installed plugins and installs missing ones', async t => {
  const calls = [];
  const f = await fixture(t, { calls, native: { claude: { id: 'demo@demo', marketplace: 'owner/demo' }, 'grok-build': { id: 'demo', source: 'https://example.com/demo' } } });
  await write(f.home, { '.claude/plugins/installed_plugins.json': JSON.stringify({ plugins: { 'demo@demo': [{ scope: 'user', version: '1.0.0' }] } }) });
  const status = (await f.vendors.list()).vendors[0].native;
  assert.equal(status.claude.installed, true); assert.equal(status['grok-build'].installed, false);
  const { results } = await f.vendors.syncNative({ name: 'demo' });
  assert.deepEqual(results.map(result => [result.target, result.action]), [['claude', 'updated'], ['grok-build', 'installed']]);
  assert.deepEqual(calls.filter(call => !call.includes('list')), [['claude', 'plugin', 'update', 'demo@demo'], ['grok', 'plugin', 'install', 'https://example.com/demo', '--trust']]);
});
