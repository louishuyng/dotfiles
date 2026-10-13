import { spawn } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { basename, isAbsolute, join } from 'node:path';
import { createInterface } from 'node:readline';
import TOML from '@iarna/toml';

export class CodexClient {
  constructor({ home = homedir(), cwd = home, executable = 'codex' } = {}) {
    this.home = home;
    this.cwd = cwd;
    this.executable = executable;
    this.pending = new Map();
    this.nextId = 0;
    this.process = null;
    this.ready = null;
  }

  start() {
    if (this.ready) return this.ready;
    const child = spawn(this.executable, ['app-server', '--stdio'], {
      cwd: this.cwd,
      env: { ...process.env, CODEX_HOME: join(this.home, '.codex') },
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    this.process = child;
    const lines = createInterface({ input: child.stdout });
    child.stderr.resume();
    const fail = (error) => {
      if (this.process !== child) return;
      this.process = null;
      this.ready = null;
      lines.close();
      child.kill();
      for (const request of this.pending.values()) {
        clearTimeout(request.timer);
        request.reject(error);
      }
      this.pending.clear();
    };
    child.on('error', (error) => fail(new Error(error.code === 'ENOENT'
      ? 'Codex executable was not found. Install Codex CLI or correct its executable path.'
      : `Codex app-server could not start (${error.code || 'process error'}).`)));
    child.on('exit', (code) => fail(new Error(`Codex app-server exited (${code ?? 'signal'}). Check Codex CLI startup and access to ~/.codex.`)));
    child.stdin.on('error', () => fail(new Error('Codex app-server input closed. Refresh to reconnect.')));
    lines.on('line', (line) => {
      let response;
      try { response = JSON.parse(line); } catch { fail(new Error('Codex app-server returned invalid JSON.')); return; }
      const request = this.pending.get(response.id);
      if (!request) return;
      this.pending.delete(response.id);
      clearTimeout(request.timer);
      if (response.error) request.reject(new Error(`Codex ${request.method} failed: ${response.error.message || 'RPC error'}`));
      else request.resolve(response.result);
    });
    this.ready = this.send('initialize', {
      clientInfo: { name: 'agent_hub', version: '1.0.0' },
      capabilities: { experimentalApi: true, requestAttestation: false },
    }).then(() => {
      child.stdin.write(`${JSON.stringify({ method: 'initialized' })}\n`);
    }).catch((error) => { fail(error); throw error; });
    return this.ready;
  }

  send(method, params) {
    return new Promise((resolve, reject) => {
      if (!this.process) { reject(new Error('Codex app-server is disconnected.')); return; }
      const id = ++this.nextId;
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Codex ${method} timed out after 15 seconds. Refresh to check whether the operation completed.`));
        this.close();
      }, 15_000);
      this.pending.set(id, { resolve, reject, timer, method });
      this.process.stdin.write(`${JSON.stringify({ id, method, params })}\n`);
    });
  }

  async call(method, params) {
    await this.start();
    return this.send(method, params);
  }

  async readConfig() {
    try {
      return TOML.parse(await readFile(join(this.home, '.codex', 'config.toml'), 'utf8'));
    } catch (error) {
      if (error.code !== 'ENOENT') throw new Error('Codex config.toml could not be read or parsed. Correct the configuration before managing skills.');
      return {};
    }
  }

  async catalogue({ includeSkills = true } = {}) {
    const warnings = [];
    const overrides = (await this.readConfig()).plugins || {};
    const installed = await this.call('plugin/installed', { cwds: [this.cwd] });
    const plugins = (installed.marketplaces || []).flatMap((marketplace) => marketplace.plugins
      .filter((plugin) => plugin.installed)
      .map((plugin) => ({ ...plugin, marketplaceName: marketplace.name, marketplacePath: marketplace.path })));
    for (const plugin of plugins) {
      if (typeof overrides[plugin.id]?.enabled === 'boolean') plugin.enabled = overrides[plugin.id].enabled;
    }
    for (const error of installed.marketplaceLoadErrors || []) warnings.push(`Codex marketplace could not load: ${error.message || 'unknown error'}`);
    if (!includeSkills) return { skills: [], plugins, warnings };
    const remote = plugins.filter((plugin) => plugin.enabled && plugin.source?.type === 'remote');
    // Remote skills enter the local catalogue only after their owning plugin is read.
    for (let index = 0; index < remote.length; index += 6) {
      await Promise.all(remote.slice(index, index + 6).map(async (plugin) => {
        try {
          await this.call('plugin/read', {
            remoteMarketplaceName: plugin.marketplaceName,
            pluginName: plugin.name,
          });
        } catch (error) {
          plugin.enabled = false;
          warnings.push(`Codex ${plugin.name} skills could not load: ${error.message}`);
        }
      }));
    }
    const result = await this.call('skills/list', { cwds: [this.cwd], forceReload: true });
    const skills = (result.data || []).flatMap((entry) => {
      for (const error of entry.errors || []) warnings.push(`Codex skill could not load: ${error.message || 'unknown error'}`);
      return entry.skills || [];
    });
    const disabled = new Set(plugins.filter((plugin) => !plugin.enabled).map((plugin) => plugin.id));
    return { skills: skills.map((skill) => ({ ...skill, enabled: skill.enabled && !disabled.has(skill.pluginId) })), plugins, warnings };
  }

  async setSkill(path, enabled) {
    if (typeof path !== 'string' || !isAbsolute(path) || typeof enabled !== 'boolean') throw new Error('A skill requires an absolute path and boolean enabled state.');
    const result = await this.call('skills/config/write', { path, enabled });
    this.close();
    return result;
  }

  async setLibrarySkills(skills) {
    if (!Array.isArray(skills) || skills.some((skill) => !skill || typeof skill.path !== 'string'
      || !isAbsolute(skill.path) || basename(skill.path) !== 'SKILL.md' || typeof skill.enabled !== 'boolean')) {
      throw new Error('Library skills require absolute SKILL.md paths and boolean enabled states.');
    }
    const paths = new Set(skills.map((skill) => skill.path));
    if (paths.size !== skills.length) throw new Error('Library skill paths must be unique.');
    const config = await this.readConfig();
    const existing = config.skills?.config ?? [];
    if (!Array.isArray(existing) || existing.some((entry) => !entry || typeof entry !== 'object')) {
      throw new Error('Codex skills.config must be a list of skill preferences before managing library skills.');
    }
    const value = [
      ...existing.filter((entry) => !paths.has(entry.path)),
      ...skills.map(({ path, enabled }) => ({ path, enabled })),
    ];
    try {
      return await this.call('config/batchWrite', {
        edits: [{ keyPath: 'skills.config', value, mergeStrategy: 'replace' }],
      });
    } finally {
      this.close();
    }
  }

  async setPlugin(pluginId, enabled) {
    if (typeof pluginId !== 'string' || !pluginId.includes('@') || typeof enabled !== 'boolean') throw new Error('A plugin requires its catalogue ID and boolean enabled state.');
    const result = await this.call('config/value/write', {
      keyPath: `plugins.${JSON.stringify(pluginId)}.enabled`,
      value: enabled,
      mergeStrategy: 'upsert',
    });
    this.close();
    return result;
  }

  close() {
    const child = this.process;
    this.process = null;
    this.ready = null;
    child?.kill();
    for (const request of this.pending.values()) {
      clearTimeout(request.timer);
      request.reject(new Error('Codex app-server connection closed. Refresh to reconnect.'));
    }
    this.pending.clear();
  }
}
