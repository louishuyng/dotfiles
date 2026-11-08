import { execFile } from 'node:child_process';
import { cp, mkdtemp, readdir, readFile, rename, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { promisify } from 'node:util';
import { executable } from './config.mjs';

const execFileAsync = promisify(execFile);
const DAY = 24 * 60 * 60 * 1000;
const NAME = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
// Branch, tag, or commit. Leading '-' would be read as a git option.
const REF = /^(?!-)(?!.*\.\.)[A-Za-z0-9._/-]{1,128}$/;

export function validRef(ref) { return typeof ref === 'string' && REF.test(ref); }

async function defaultRun(command, args, options = {}) {
  const file = executable(command) || command;
  const { stdout } = await execFileAsync(file, args, { timeout: 120000, maxBuffer: 8 * 1024 * 1024, ...options });
  return stdout;
}

async function files(root, include, exclude) {
  const found = new Map();
  async function walk(relative) {
    if (exclude.some(item => relative === item || relative.startsWith(`${item}/`))) return;
    const full = path.join(root, relative);
    const entries = await readdir(full, { withFileTypes: true }).catch(error => (error.code === 'ENOTDIR' ? null : Promise.reject(error)));
    if (!entries) { found.set(relative, await readFile(full)); return; }
    for (const entry of entries) await walk(path.posix.join(relative, entry.name));
  }
  for (const item of include) await walk(item).catch(error => { if (error.code !== 'ENOENT') throw error; });
  return found;
}

export class Vendors {
  constructor({ root, home, data, run = defaultRun, now = () => Date.now() }) {
    Object.assign(this, { root, home, data, run, now });
    this.dir = path.join(root, 'ai/vendor');
    this.stages = new Map();
  }

  async manifest(name) {
    if (!NAME.test(name || '')) throw new Error('Choose a vendored plugin.');
    const value = JSON.parse(await readFile(path.join(this.dir, name, 'vendor.json'), 'utf8'));
    if (value.name !== name || !value.repo || !validRef(value.ref) || !Array.isArray(value.include) || !value.include.length) throw new Error(`${name}/vendor.json is incomplete.`);
    return { ...value, exclude: value.exclude || [], native: value.native || {} };
  }

  async cache() { return JSON.parse(await readFile(path.join(this.data, 'vendors.json'), 'utf8').catch(() => '{}')); }
  async saveCache(value) { await writeFile(path.join(this.data, 'vendors.json'), JSON.stringify(value, null, 2), { mode: 0o600 }); }

  async list() {
    const entries = await readdir(this.dir, { withFileTypes: true }).catch(() => []);
    const cache = await this.cache();
    const vendors = [];
    for (const entry of entries.filter(item => item.isDirectory())) {
      let manifest; try { manifest = await this.manifest(entry.name); } catch { continue; }
      vendors.push({ ...manifest, path: path.join(this.dir, entry.name), latest: cache[entry.name], native: await this.nativeStatus(manifest) });
    }
    return { vendors };
  }

  async nativeStatus(manifest) {
    const status = {};
    for (const [target, spec] of Object.entries(manifest.native)) {
      try {
        if (target === 'claude') {
          const installed = JSON.parse(await readFile(path.join(this.home, '.claude/plugins/installed_plugins.json'), 'utf8')).plugins?.[spec.id];
          const entry = Array.isArray(installed) ? installed.find(item => item.scope === 'user') || installed[0] : installed;
          status[target] = { id: spec.id, installed: !!entry, version: entry?.version, commit: entry?.gitCommitSha };
        } else if (target === 'grok-build') {
          const plugin = JSON.parse(await this.run('grok', ['plugin', 'list', '--json'], { timeout: 15000 })).find(item => item.name === spec.id);
          status[target] = { id: spec.id, installed: !!plugin, version: plugin?.version };
        } else status[target] = { id: spec.id, installed: false, error: 'Unsupported agent.' };
      } catch (error) {
        status[target] = { id: spec.id, installed: false, error: error.code === 'ENOENT' ? 'Not installed on this Mac.' : 'Status could not be read.' };
      }
    }
    return status;
  }

  async check(name) {
    const manifest = await this.manifest(name);
    const cache = await this.cache();
    try {
      const line = (await this.run('git', ['ls-remote', '--', manifest.repo, manifest.ref], { timeout: 30000 })).split('\n').find(Boolean);
      cache[name] = { commit: line?.split('\t')[0], ref: manifest.ref, checkedAt: new Date(this.now()).toISOString() };
    } catch {
      cache[name] = { ...cache[name], error: 'Upstream could not be reached.', checkedAt: new Date(this.now()).toISOString() };
    }
    await this.saveCache(cache);
    return cache[name];
  }

  async checkStale() {
    const cache = await this.cache();
    const entries = await readdir(this.dir, { withFileTypes: true }).catch(() => []);
    for (const name of entries.filter(entry => entry.isDirectory() && NAME.test(entry.name)).map(entry => entry.name)) {
      try { await this.manifest(name); } catch { continue; }
      if (!cache[name] || this.now() - Date.parse(cache[name].checkedAt) > DAY) await this.check(name);
    }
  }

  async preview({ name, ref }) {
    const manifest = await this.manifest(name);
    ref = ref || manifest.ref;
    if (!validRef(ref)) throw new Error('Use a branch, tag, or commit name.');
    await this.discard(name);
    const stage = await mkdtemp(path.join(tmpdir(), `agent-hub-vendor-${name}-`));
    try {
      const repo = path.join(stage, 'repo');
      await this.run('git', ['clone', '--quiet', '--no-checkout', '--', manifest.repo, repo], { timeout: 180000 });
      await this.run('git', ['-C', repo, 'checkout', '--quiet', '--detach', ref, '--']).catch(() => { throw new Error(`Upstream has no ref named ${ref}.`); });
      for (const item of manifest.include) await readFile(path.join(repo, item)).catch(error => { if (error.code !== 'EISDIR') throw new Error(`Upstream no longer has ${item}. Review the wrapper skill before updating.`); });
      const [commit, date] = (await this.run('git', ['-C', repo, 'log', '-1', '--format=%H %cs'])).trim().split(' ');
      const plugin = JSON.parse(await readFile(path.join(repo, 'plugin.json'), 'utf8').catch(() => '{}'));
      const next = await files(repo, manifest.include, manifest.exclude);
      const current = await files(path.join(this.dir, name), manifest.include, manifest.exclude);
      const changes = [];
      for (const [file, content] of next) if (!current.has(file)) changes.push({ path: file, status: 'added' }); else if (!current.get(file).equals(content)) changes.push({ path: file, status: 'changed' });
      for (const file of current.keys()) if (!next.has(file)) changes.push({ path: file, status: 'removed' });
      changes.sort((a, b) => a.path.localeCompare(b.path));
      const id = `${name}-${commit.slice(0, 12)}-${this.now()}`;
      this.stages.set(name, { id, stage, repo, ref, commit, date, version: plugin.version || manifest.version });
      return { id, name, ref, commit, date, version: plugin.version || manifest.version, from: { commit: manifest.commit, version: manifest.version }, changes };
    } catch (error) {
      await rm(stage, { recursive: true, force: true }); throw error;
    }
  }

  async discard(name) {
    const staged = this.stages.get(name);
    if (staged) { this.stages.delete(name); await rm(staged.stage, { recursive: true, force: true }); }
    return { ok: true };
  }

  async apply({ name, id }) {
    const manifest = await this.manifest(name);
    const staged = this.stages.get(name);
    if (!staged || staged.id !== id) throw new Error('This preview expired. Check for updates again.');
    const target = path.join(this.dir, name);
    const suffix = `${process.pid}-${this.now()}`;
    const next = `${target}.next-${suffix}`; const previous = `${target}.prev-${suffix}`;
    try {
      for (const item of manifest.include) await cp(path.join(staged.repo, item), path.join(next, item), { recursive: true });
      for (const item of manifest.exclude) await rm(path.join(next, item), { recursive: true, force: true });
      await writeFile(path.join(next, 'vendor.json'), `${JSON.stringify({ ...manifest, commit: staged.commit, version: staged.version, date: staged.date }, null, 2)}\n`);
      await rename(target, previous);
      try { await rename(next, target); } catch (error) { await rename(previous, target); throw error; }
      await rm(previous, { recursive: true, force: true });
    } finally {
      await rm(next, { recursive: true, force: true });
      await this.discard(name);
    }
    return { ok: true, commit: staged.commit, version: staged.version };
  }

  async syncNative({ name }) {
    const manifest = await this.manifest(name);
    const status = await this.nativeStatus(manifest);
    const results = [];
    for (const [target, spec] of Object.entries(manifest.native)) {
      const installed = status[target]?.installed;
      try {
        if (target === 'claude') {
          if (!installed) {
            await this.run('claude', ['plugin', 'marketplace', 'add', spec.marketplace]).catch(() => {});
            await this.run('claude', ['plugin', 'install', spec.id]);
          } else await this.run('claude', ['plugin', 'update', spec.id]);
        } else if (target === 'grok-build') {
          // --trust is required for git installs; the source comes from the repository-owned vendor.json.
          if (!installed) await this.run('grok', ['plugin', 'install', spec.source, '--trust']);
          else await this.run('grok', ['plugin', 'update', spec.id]);
        } else throw new Error('Unsupported agent.');
        results.push({ target, ok: true, action: installed ? 'updated' : 'installed' });
      } catch (error) {
        results.push({ target, ok: false, error: error.code === 'ENOENT' ? 'CLI not installed.' : (error.stderr || error.message || 'Failed.').toString().trim().split('\n').pop() });
      }
    }
    return { results };
  }
}
