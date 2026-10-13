import { readFile, writeFile, mkdir, realpath, stat, readdir, rename, lstat, readlink, symlink, rm } from 'node:fs/promises';
import { existsSync, constants, accessSync } from 'node:fs';
import { createHash, randomUUID } from 'node:crypto';
import path from 'node:path';
import TOML from '@iarna/toml';
import { parse as parseJSONC, modify, applyEdits } from 'jsonc-parser';
import { parse as parseYAML } from 'yaml';

export const hash = (value) => createHash('sha256').update(value).digest('hex');
export function executable(name) {
  for (const root of (process.env.PATH || '').split(path.delimiter)) {
    const file = path.join(root, name); try { accessSync(file, constants.X_OK); return file; } catch {}
  }
  return null;
}
export function jsonc(content) {
  const errors = []; const result = parseJSONC(content, errors, { allowTrailingComma: true });
  if (errors.length || !result || Array.isArray(result) || typeof result !== 'object') throw new Error('Expected a valid JSON object (comments and trailing commas are allowed).');
  return result;
}
async function resolvedTarget(file) {
  const missing = []; let current = file;
  for (;;) {
    try { return path.join(await realpath(current), ...missing.reverse()); }
    catch (error) { if (error.code !== 'ENOENT') throw error; const parent=path.dirname(current); if(parent===current)throw error; missing.push(path.basename(current)); current=parent; }
  }
}
async function optional(file, fallback = '') { try { return await readFile(file, 'utf8'); } catch (error) { if (error.code === 'ENOENT') return fallback; throw error; } }
export const TOOL_DEFINITIONS = [
  ['codex', 'Codex Desktop', 'openai', '#222222', 'codex', '.codex', 'https://learn.chatgpt.com/docs/codex', ['skills','plugins','hooks','instructions','usage'], 'Desktop and CLI share the local Codex configuration.'],
  ['claude', 'Claude Code', 'claude', '#D97757', 'claude', '.claude', 'https://code.claude.com/docs', ['skills','plugins','hooks','instructions','usage'], 'Native configuration and local session history.'],
  ['opencode', 'OpenCode', 'opencode', '#595959', 'opencode', '.config/opencode', 'https://opencode.ai/v2/docs', ['skills','plugins','hooks','instructions','usage'], 'OpenCode v2 plugins and recorded session usage.'],
  ['grok', 'Grok', 'grok', '#222222', 'grok', '.grok', 'https://grok.com', [], 'SuperGrok web account. Web conversation usage is not exposed in local logs.'],
  ['grok-build', 'Grok Build', 'grok', '#222222', 'grok', '.grok', 'https://docs.x.ai/build', ['skills','instructions'], 'Local coding CLI; separate from the SuperGrok web account.'],
  ['gemini', 'Gemini CLI', 'gemini', '#4285F4', 'gemini', '.gemini', 'https://geminicli.com/docs', ['skills','hooks','instructions'], 'Shares Agent Skills; Gemini settings hooks remain native.'],
  ['copilot', 'GitHub Copilot', 'githubcopilot', '#6F42C1', 'copilot', '.copilot', 'https://docs.github.com/en/copilot', ['skills','instructions'], 'Personal skills and explicitly selected project instructions.'],
  ['cursor', 'Cursor', 'cursor', '#222222', 'cursor-agent', '.cursor', 'https://cursor.com/docs', ['skills','hooks','instructions'], 'Skill and hook files; IDE billing/usage requires a supported export.'],
  ['pi', 'Pi', 'pi', '#E8A338', 'pi', '.pi/agent', 'https://github.com/earendil-works/pi', ['skills','instructions','usage'], 'Native Agent Skills and JSONL session usage.'],
  ['goose', 'Goose', 'goose', '#D8A128', 'goose', '.config/goose', 'https://block.github.io/goose/docs', [], 'Detected local tool; native configuration adapter is not available yet.'],
  ['amp', 'Amp', 'amp', '#E65039', 'amp', '.config/amp', 'https://ampcode.com/manual', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['windsurf', 'Windsurf', 'windsurf', '#00B9A4', 'windsurf', '.codeium/windsurf', 'https://docs.windsurf.com', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['antigravity', 'Antigravity', 'antigravity', '#4285F4', 'agy', '.gemini/antigravity', 'https://antigravity.google', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['cline', 'Cline', 'cline', '#5666FF', '', '.cline', 'https://docs.cline.bot', [], 'IDE extension; configure in its native application.'],
  ['roo', 'Roo Code', 'roocode', '#B08CFA', '', '.roo', 'https://docs.roocode.com', [], 'IDE extension; configure in its native application.'],
  ['kilo', 'Kilo Code', 'kilocode', '#F7D046', 'kilo', '.kilocode', 'https://kilo.ai/docs', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['qwen', 'Qwen Code', 'qwen', '#615CED', 'qwen', '.qwen', 'https://qwenlm.github.io/qwen-code-docs', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['kiro', 'Kiro', 'kiro', '#8C5CFF', 'kiro-cli', '.kiro', 'https://kiro.dev/docs', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['droid', 'Factory Droid', 'factory', '#E96B35', 'droid', '.factory', 'https://docs.factory.ai', [], 'Local configuration detected; native adapter unavailable.'],
  ['aider', 'Aider', 'aider', '#00A67E', 'aider', '.aider.conf.yml', 'https://aider.chat/docs', [], 'Catalogue entry; configuration and usage integration unavailable.'],
  ['continue', 'Continue', 'continue', '#383838', 'cn', '.continue', 'https://docs.continue.dev', [], 'IDE/CLI catalogue entry; native adapter unavailable.'],
];
export class Configuration {
  constructor({ home, root, data, codex }) { this.home = path.resolve(home); this.root = path.resolve(root); this.data = path.resolve(data); this.codex = codex; this.documents = new Map(); this.catalogue = null; this.catalogueTime = 0; this.skillAuditTime=0; }
  async init() { await mkdir(this.data, { recursive: true, mode: 0o700 }); await mkdir(path.join(this.data, 'backups'), { recursive: true, mode: 0o700 }); this.home=await realpath(this.home); this.root=await realpath(this.root); this.data=await realpath(this.data); }
  async readState() { return jsonc(await optional(path.join(this.data, 'state.json'), '{}')); }
  async saveState(value) { await this.atomic(path.join(this.data, 'state.json'), JSON.stringify(value, null, 2)); }
  document(id, name, tool, file, kind, options = {}) {
    const sourcePath=kind==='instruction'&&!options.project?path.join(this.root,'ai/AGENTS.md'):kind==='hook'?path.join(this.root,'ai/hooks',`${tool}.json`):((kind==='config'&&id.startsWith('native:'))||id==='plugins:opencode')?path.join(this.root,'ai/config',`${id.replace(':','-')}.json`):undefined;
    const value = { id, name, tool, path: file, sourcePath, kind, exists: existsSync(sourcePath||file), editable: true, ...options };
    this.documents.set(id, value); return value;
  }
  async discover(force = false) {
    if (this.catalogue && !force && Date.now() - this.catalogueTime < 60000) return this.catalogue;
    try { this.catalogue = await this.codex.catalogue({includeSkills:false}); }
    catch(error) { this.catalogue = {skills:[],plugins:[],warnings:[error.message]}; }
    this.catalogueTime = Date.now(); return this.catalogue;
  }
  async library() {
    const directory=path.join(this.root,'ai/skills');
    const file=path.join(directory,'manifest.json');
    const manifest=jsonc(await optional(file,'{"name":"LX14-AI-Skills"}'));
    if(manifest.name!=='LX14-AI-Skills' || (manifest.enabled!==undefined && (!Array.isArray(manifest.enabled)||manifest.enabled.some((n)=>typeof n!=='string'))))throw new Error('Invalid LX14-AI-Skills manifest.');
    const skills=[];
    for(const folder of (await readdir(directory,{withFileTypes:true})).sort((a,b)=>a.name.localeCompare(b.name))) {
      if(!folder.isDirectory()&&!folder.isSymbolicLink())continue;
      const file=path.join(directory,folder.name,'SKILL.md');if(!existsSync(file))continue;
      const target=await realpath(file);if(!target.startsWith(directory+path.sep))throw new Error('Shared skills must resolve inside ai/skills.');
      const text=await readFile(target,'utf8');this.validate({format:'skill'},text);
      const meta=parseYAML(text.match(/^---\r?\n([\s\S]*?)\r?\n---/)[1]);
      if(!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(meta.name)||meta.name!==folder.name)throw new Error(`Skill folder and name must match: ${folder.name}`);
      skills.push({id:hash(file).slice(0,16),name:meta.name,description:meta.description,path:file,source:manifest.name,enabled:manifest.enabled===undefined||manifest.enabled.includes(meta.name),editable:true,compatibility:'Portable instructions'});
    }
    if(manifest.enabled?.some((name)=>!skills.some((s)=>s.name===name)))throw new Error('An enabled skill is missing from LX14-AI-Skills.');
    return {name:manifest.name,path:directory,skills,manifest};
  }
  async writeLibrary(skills) {
    const file=path.join(this.root,'ai/skills/manifest.json');
    this.document('library:manifest','Library manifest','shared',file,'config',{format:'json'});
    await this.backup(file,'library:manifest');
    await this.atomic(file,JSON.stringify({name:'LX14-AI-Skills',enabled:skills.filter((s)=>s.enabled).map((s)=>s.name)},null,2)+'\n');this.skillAuditTime=0;
  }
  async inventory() {
    const saved = await this.readState(); const library=await this.library(); const native = await this.discover(); const warnings = [...(native.warnings || [])];
    const tools = TOOL_DEFINITIONS.map(([id, name, icon, color, command, config, url, capabilities, note]) => ({ id, name, icon: `/icons/${icon}.svg`, color, installed: !!command && !!executable(command), configured: existsSync(path.join(this.home, config)) || id === 'grok', kind: id === 'grok' ? 'Web account' : ['cursor','windsurf','antigravity','cline','roo','continue'].includes(id) ? 'Editor' : 'Agent', url, capabilities, note, ...(id === 'grok' ? { subscription: 'SuperGrok' } : {}) }));
    const docs = [
      this.document('instructions:codex', 'Global instructions', 'codex', path.join(this.home, '.codex/AGENTS.md'), 'instruction'),
      this.document('instructions:claude', 'Global instructions', 'claude', path.join(this.home, '.claude/CLAUDE.md'), 'instruction'),
      this.document('instructions:opencode', 'Global instructions', 'opencode', path.join(this.home, '.config/opencode/AGENTS.md'), 'instruction'),
      this.document('hooks:codex', 'Codex lifecycle hooks', 'codex', path.join(this.home, '.codex/hooks.json'), 'hook', { format: 'json' }),
      this.document('hooks:claude', 'Claude lifecycle hooks', 'claude', path.join(this.home, '.claude/settings.json'), 'hook', { projection: ['hooks'], format: 'json' }),
      this.document('plugins:opencode', 'OpenCode plugin registrations', 'opencode', path.join(this.home, '.config/opencode/opencode.jsonc'), 'plugin', { projection: ['plugins'], format: 'json' }),
    ];
    docs.push(this.document('native:opencode-skills', 'OpenCode additional skill roots', 'opencode', path.join(this.home,'.config/opencode/opencode.jsonc'), 'config', {projection:['skills'],format:'json'}));
    docs.push(this.document('native:codex', 'Codex plugin settings', 'codex', path.join(this.home,'.codex/config.toml'), 'config', {projection:['plugins'],parser:'toml',format:'json',nativeToggleOnly:true}));
    docs.push(this.document('native:pi','Pi skill discovery','pi',path.join(this.home,'.pi/agent/settings.json'),'config',{projection:['skills'],format:'json'}));
    docs.push(this.document('native:claude', 'Claude plugin settings', 'claude', path.join(this.home,'.claude/settings.json'), 'config', {projection:['enabledPlugins'],format:'json'}));
    for (const [tool, file, hookfile] of [['gemini','.gemini/GEMINI.md','.gemini/settings.json'],['cursor','.cursor/AGENTS.md','.cursor/hooks.json'],['pi','.pi/agent/AGENTS.md',null],['grok-build','.grok/AGENTS.md',null]]) {
      if (!tools.find((t) => t.id === tool)?.configured) continue;
      // Cursor global AGENTS.md is not a verified native root; use selected-project instructions instead.
      if (tool !== 'cursor') docs.push(this.document(`instructions:${tool}`, 'Global instructions', tool, path.join(this.home, file), 'instruction'));
      if (hookfile) docs.push(this.document(`hooks:${tool}`, 'Lifecycle hooks', tool, path.join(this.home, hookfile), 'hook', { format: 'json', ...(tool === 'gemini' ? { projection: ['hooks'] } : {}) }));
    }
    for (const project of saved.projects || []) {
      for (const [name, relative, tool] of [['AGENTS.md','AGENTS.md','shared'],['CLAUDE.md','CLAUDE.md','claude'],['GEMINI.md','GEMINI.md','gemini'],['Copilot instructions','.github/copilot-instructions.md','copilot']]) docs.push(this.document(`project:${hash(project).slice(0,12)}:${tool}`, `${path.basename(project)} · ${name}`, tool, path.join(project, relative), 'instruction', { project }));
    }
    const skills=library.skills;
    this.document('library:manifest','Library manifest','shared',path.join(library.path,'manifest.json'),'config',{format:'json'});
    for(const skill of skills) {
      skill.documentId=`skill:${skill.id}`;
      docs.push(this.document(skill.documentId,skill.name,'shared',skill.path,'skill',{format:'skill'}));
    }
    const plugins = (native.plugins || []).map((p) => ({ id: p.id || `${p.name}@${p.marketplaceName || p.marketplace}`, tool: 'codex', name: p.name, enabled: p.enabled !== false, version: p.version || p.localVersion, path: p.path, manageable: true }));
    const claudeSettings = jsonc(await optional(path.join(this.home, '.claude/settings.json'), '{}'));
    const claudePlugins = jsonc(await optional(path.join(this.home, '.claude/plugins/installed_plugins.json'), '{}')).plugins || {};
    for (const [id, installed] of Object.entries(claudePlugins)) { const p = Array.isArray(installed) ? installed.find((x) => x.scope === 'user') || installed[0] : installed; plugins.push({ id, tool: 'claude', name: id.split('@')[0], enabled: claudeSettings.enabledPlugins?.[id] !== false, version: p?.version, path: p?.installPath, manageable: !!(Array.isArray(installed) && installed.some((x) => x.scope === 'user')), note: 'Restart Claude Code after changing plugin state.' }); }
    const oc = jsonc(await optional(path.join(this.home, '.config/opencode/opencode.jsonc'), '{}'));
    for (const value of oc.plugins || []) { const p = typeof value === 'string' ? value : value.package; plugins.push({ id: p, tool: 'opencode', name: path.basename(p), path: p, enabled: true, manageable: true, note: 'Restart OpenCode to reload plugin registrations.' });
      if (path.isAbsolute(p) && [`${this.root}/opencode/plugins/`,`${this.root}/ai/plugins/`].some(root=>path.resolve(p).startsWith(root))) {
        const source=await realpath(p);for (const name of ['index.ts','index.js','index.mjs','src/index.ts']) if (existsSync(path.join(source,name))) docs.push(this.document(`source:${hash(path.join(source,name)).slice(0,12)}`, `${path.basename(source)} · ${name}`, 'opencode', path.join(source,name), 'hook-source', { format: 'source' }));
      }
    }
    for (const [id] of Object.entries(saved.disabledOpenCode || {})) plugins.push({ id, tool: 'opencode', name: path.basename(id), path: id, enabled: false, manageable: true });
    const hooks = [];
    for (const doc of docs.filter((d) => d.kind === 'hook')) {
      try { const data = await this.readDocument(doc.id); const value = jsonc(data.content); const events = value.hooks || value;
        for (const [name, entries] of Object.entries(events)) if (Array.isArray(entries)) hooks.push({ tool: doc.tool, event: name, count: entries.reduce((n, entry) => n + (Array.isArray(entry.hooks) ? entry.hooks.length : 1),0), documentId: doc.id, description: 'Configured lifecycle actions' });
      } catch (error) { warnings.push(`${doc.tool} hooks: ${error.message}`); }
    }
    for (const p of plugins.filter((p) => p.tool === 'opencode' && p.enabled)) hooks.push({ tool: 'opencode', event: p.name, count: 1, documentId: 'plugins:opencode', description: 'Native v2 plugin lifecycle hooks' });
    const checks=[];
    const audit=saved.sync?await this.nativeSkillAudit(library):null;
    const activeSkills=skills.filter((s)=>s.enabled);
    if(saved.sync)for(const tool of saved.sync.targets) {
      const change=(await this.syncTargets()).find((c)=>c.target===tool);if(!change)continue;
      const enabled=activeSkills;
      const issues=[...(audit?.issues[tool]||[])];let matched=0;
      const names=await readdir(change.path).catch(()=>[]);
      for(const s of enabled) {
        const name=s.name.replace(/[^a-zA-Z0-9-]/g,'-');
        try {if(await realpath(path.join(change.path,name))===await realpath(path.dirname(s.path)))matched++;else issues.push(`${s.name}: different source folder`);}
        catch {issues.push(`${s.name}: missing or unreadable`);}
      }
      const expectedNames=new Set(enabled.map((s)=>s.name.replace(/[^a-zA-Z0-9-]/g,'-')));
      for(const name of names)if(!expectedNames.has(name))issues.push(`${name}: extra exported skill`);
      try {if(!(await lstat(change.path)).isSymbolicLink()||path.resolve(path.dirname(change.path),await readlink(change.path))!==change.source)issues.push('Shared root was replaced outside Agent Hub');}catch {issues.push('Shared root is missing');}
      checks.push({target:tool,matched,expected:enabled.length,status:issues.length?'drift':'synced',issues});
    }
    return { library:{name:library.name,path:library.path}, tools, skills, plugins, documents: docs.map(({ projection, format, project, sourcePath, ...d }) => ({...d,path:sourcePath||d.path,editable:d.editable&&!d.nativeToggleOnly})), hooks, warnings, refreshedAt: new Date().toISOString(), sync: { managed: saved.sync?.count || 0, targets: saved.sync?.targets || [],checks,warnings:['Verification covers global skills. Existing sessions must restart; project-level skill sources can add skills.'],verifiedAt:new Date().toISOString() }, backups: saved.backups || [] };
  }
  async resolveDocument(id) {
    const doc = this.documents.get(id); if (!doc) throw new Error('Unknown document. Refresh the inventory first.');
    const target = await resolvedTarget(doc.path);
    if(doc.sourcePath&&await resolvedTarget(doc.sourcePath)!==doc.sourcePath)throw new Error('Global configuration sources must be real files inside dotfiles/ai.');
    if (doc.project) {
      const project = await realpath(doc.project);
      if (!target.startsWith(`${project}${path.sep}`)) throw new Error('This project file links outside the selected project. Edit its source directly.');
    } else {
      const allowed = [this.root, path.join(this.home, '.codex'), path.join(this.home,'.claude'), path.join(this.home,'.config/opencode'), path.join(this.home,'.gemini'), path.join(this.home,'.cursor'), path.join(this.home,'.pi/agent'), path.join(this.home,'.grok')];
      if (!allowed.some((root) => target.startsWith(`${root}${path.sep}`))) throw new Error('The symlink target is outside managed configuration roots.');
    }
    return { doc, target };
  }
  async readDocument(id) {
    const { doc, target } = await this.resolveDocument(id); const raw = await optional(target);
    if (Buffer.byteLength(raw) > 2 * 1024 * 1024) throw new Error('Document exceeds the 2 MB editing limit.');
    let parsed;
    if (doc.projection) {
      try { parsed=doc.parser==='toml'?TOML.parse(raw):jsonc(raw || '{}'); }
      catch { throw new Error('Configuration syntax is invalid. Repair it in the native tool before editing.'); }
    }
    const projected = doc.projection ? JSON.stringify(parsed[doc.projection[0]] ?? (['plugins','skills'].includes(doc.projection[0]) && doc.parser!=='toml' ? [] : {}), null, 2) : raw;
    if(doc.sourcePath&&!existsSync(doc.sourcePath))await this.atomic(doc.sourcePath,projected);
    const content=doc.sourcePath?await readFile(doc.sourcePath,'utf8'):projected;
    return { id, content, revision: hash(raw+(doc.sourcePath?content:'')), path: doc.sourcePath||target, editable: doc.editable && !doc.nativeToggleOnly };
  }
  validate(doc, content) {
    if (typeof content !== 'string' || Buffer.byteLength(content) > 2 * 1024 * 1024) throw new Error('Content must be text shorter than 2 MB.');
    if (doc.format === 'json') {
      let value; try { value = JSON.parse(content); } catch { throw new Error('Fix the JSON syntax before saving.'); }
      if (!value || typeof value !== 'object') throw new Error('Expected JSON configuration.');
      if (doc.projection?.[0] === 'plugins' && (!Array.isArray(value) || value.some((p) => typeof p !== 'string' && (typeof p !== 'object' || typeof p.package !== 'string')))) throw new Error('Each plugin needs a package string or an object with a package field.');
      if(doc.projection?.[0]==='skills' && (!Array.isArray(value)||value.some((s)=>typeof s!=='string')))throw new Error('Skill sources must be an array of paths or catalog URLs.');
      if(doc.projection?.[0]==='enabledPlugins' && (Array.isArray(value)||Object.values(value).some((v)=>typeof v!=='boolean')))throw new Error('Plugin enablement must map plugin IDs to booleans.');
      if (doc.kind === 'hook' && (Array.isArray(value) || Object.values(value.hooks || value).some((v) => !Array.isArray(v)))) throw new Error('Hook events must map to arrays of native hook registrations.');
    }
    if (doc.format === 'skill') {
      const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/); if (!match) throw new Error('Add YAML frontmatter with name and description.');
      const meta = parseYAML(match[1]); if (typeof meta?.name !== 'string' || typeof meta?.description !== 'string' || !meta.name.trim() || !meta.description.trim()) throw new Error('Skill name and description must be non-empty text.');
      if(doc.path&&meta.name!==path.basename(path.dirname(doc.path)))throw new Error('Keep the skill name equal to its source folder name.');
    }
  }
  async backup(file, documentId) {
    const content = await optional(file); const id = randomUUID();
    const existed = existsSync(file);
    await writeFile(path.join(this.data,'backups',`${id}.json`), JSON.stringify({ path: file, content, existed, documentId }), { mode: 0o600 });
    const saved = await this.readState(); saved.backups = [{ id, name: path.basename(file), createdAt: new Date().toISOString(), documentId }, ...(saved.backups || [])]; await this.saveState(saved); return id;
  }
  async atomic(file, content) {
    await mkdir(path.dirname(file), { recursive: true, mode: 0o700 });
    const temporary = `${file}.agent-hub-${randomUUID()}`;
    const mode = existsSync(file) ? (await stat(file)).mode & 0o777 : 0o600;
    try { await writeFile(temporary, content, { mode, flag: 'wx' }); await rename(temporary,file); }
    finally { await rm(temporary, { force: true }); }
  }
  async saveDocument({ id, content, revision }) {
    const { doc, target } = await this.resolveDocument(id); if (!doc.editable) throw new Error('This managed plugin content is read-only.');
    this.validate(doc, content); const current = await optional(target);
    const source=doc.sourcePath?await optional(doc.sourcePath):'';
    if (hash(current+source) !== revision) throw new Error('This file changed outside Agent Hub. Reload it before saving.');
    if(doc.nativeToggleOnly || doc.parser==='toml') throw new Error('Manage Codex enablement using its native toggles.');
    const next = doc.projection ? applyEdits(current || '{}', modify(current || '{}', doc.projection, JSON.parse(content), { formattingOptions: { insertSpaces: true, tabSize: 2, eol: '\n' } })) : content;
    await this.backup(target,id);await this.atomic(target,next);
    if(doc.sourcePath&&doc.sourcePath!==target)try {await this.atomic(doc.sourcePath,content);}catch(error){await this.atomic(target,current);throw error;}
    this.catalogueTime = 0; this.skillAuditTime=0;
    return this.readDocument(id);
  }
  async restore({ backupId, revision }) {
    if (!/^[\da-f-]{36}$/.test(backupId)) throw new Error('Unknown backup.');
    const backup = JSON.parse(await readFile(path.join(this.data,'backups',`${backupId}.json`),'utf8'));
    const { target, doc } = await this.resolveDocument(backup.documentId);
    if (target !== backup.path || !doc.editable) throw new Error('The backup belongs to a different file target.');
    const current = await optional(target);const source=doc.sourcePath?await optional(doc.sourcePath):''; if (hash(current+source) !== revision) throw new Error('Reload the current file before restoring its backup.');
    await this.backup(target,backup.documentId);
    if (backup.existed) await this.atomic(target,backup.content); else await rm(target,{force:true});
    await this.captureSource(backup.documentId);this.catalogueTime = 0; this.skillAuditTime=0; return this.readDocument(backup.documentId);
  }
  async captureSource(id) {
    const {doc,target}=await this.resolveDocument(id);if(!doc.sourcePath||doc.sourcePath===target)return;
    const raw=await optional(target,doc.parser==='toml'?'':doc.projection?'{}':'');
    let content=raw;
    if(doc.projection) {let value;try {value=doc.parser==='toml'?TOML.parse(raw):jsonc(raw);}catch {throw new Error('Native configuration syntax is invalid. Repair it before exporting settings.');}content=JSON.stringify(value[doc.projection[0]]??(['plugins','skills'].includes(doc.projection[0])&&doc.parser!=='toml'?[]:{}),null,2);}
    await this.atomic(doc.sourcePath,content);
  }
  async configureGlobals() {
    await this.inventory();
    for(const doc of this.documents.values()) {
      if(!doc.sourcePath)continue;
      const data=await this.readDocument(doc.id);
      if(doc.kind==='instruction'||(doc.kind==='hook'&&!doc.projection)) {
        const info=await lstat(doc.path).catch(()=>null);
        if(info?.isSymbolicLink()&&await realpath(doc.path).catch(()=>null)===doc.sourcePath)continue;
        await mkdir(path.dirname(doc.path),{recursive:true});
        let previous;
        if(info){previous=path.join(this.data,'original-global-files',`${doc.id.replace(':','-')}-${randomUUID()}`);await mkdir(path.dirname(previous),{recursive:true,mode:0o700});await rename(doc.path,previous);}
        try {await symlink(doc.sourcePath,doc.path);}catch(error){if(previous)await rename(previous,doc.path);throw error;}
        continue;
      }
      if(doc.nativeToggleOnly) {
        const wanted=JSON.parse(data.content);const {target}=await this.resolveDocument(doc.id);const current=TOML.parse(await optional(target,'')).plugins||{};
        for(const [id,value] of Object.entries(wanted))if(typeof value.enabled==='boolean'&&current[id]?.enabled!==value.enabled){await this.backup(target,doc.id);await this.codex.setPlugin(id,value.enabled);}
      } else {
        const {target}=await this.resolveDocument(doc.id);const raw=await optional(target,'{}');const wanted=JSON.parse(data.content);
        const current=jsonc(raw)[doc.projection[0]];
        if(JSON.stringify(current)!==JSON.stringify(wanted))await this.saveDocument({...data,content:data.content});
      }
    }
  }
  async createSkill({ name, description, content }) {
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name || '') || name.length > 80) throw new Error('Use a skill name with lowercase letters, numbers, and hyphens.');
    if (typeof description !== 'string' || !description.trim() || description.length > 2000) throw new Error('Add a description shorter than 2,000 characters.');
    const dir = path.join(this.root,'ai/skills',name); if (existsSync(dir)) throw new Error('A skill with this name already exists.');
    const text = `---\nname: ${JSON.stringify(name)}\ndescription: ${JSON.stringify(description.trim())}\n---\n\n${typeof content === 'string' ? content : ''}\n`;
    this.validate({format:'skill'},text);const library=await this.library(); await mkdir(dir); await this.atomic(path.join(dir,'SKILL.md'),text);await this.writeLibrary([...library.skills,{name,enabled:true}]); return {ok:true};
  }
  async selectProject({ path: selected }) {
    if (typeof selected !== 'string' || !path.isAbsolute(selected)) throw new Error('Enter an absolute local project directory.');
    const project = await realpath(selected);
    if (!(await stat(project)).isDirectory() || !project.startsWith(`${this.home}/`) || project === this.home || /\/(?:\.ssh|\.aws|\.codex|\.claude|Library)(?:\/|$)/.test(project)) throw new Error('Choose a project directory inside your home folder.');
    const saved = await this.readState(); saved.projects = [...new Set([...(saved.projects || []),project])]; await this.saveState(saved); return {ok:true};
  }
  async togglePlugin({tool,id,enabled}) {
    if (typeof enabled !== 'boolean') throw new Error('Enablement must be true or false.');
    const inventory = await this.inventory(); const plugin = inventory.plugins.find((p) => p.tool === tool && p.id === id); if (!plugin?.manageable) throw new Error('Manage this plugin in its native tool.');
    if (tool === 'codex') { const {target:file}=await this.resolveDocument('native:codex'); await this.backup(file, 'native:codex'); await this.codex.setPlugin(id,enabled); }
    else if (tool === 'claude') {
      const {target:file}=await this.resolveDocument('native:claude'); const raw=await optional(file,'{}'); await this.backup(file,'native:claude'); await this.atomic(file,applyEdits(raw,modify(raw,['enabledPlugins',id],enabled,{formattingOptions:{insertSpaces:true,tabSize:2}})));
    } else if (tool === 'opencode') {
      const current=await this.readDocument('plugins:opencode'); const entries=JSON.parse(current.content); const saved=await this.readState(); saved.disabledOpenCode ||= {};
      const index=entries.findIndex((p)=>(typeof p==='string'?p:p.package)===id);
      if (!enabled && index >= 0) saved.disabledOpenCode[id]=entries.splice(index,1)[0];
      if (enabled && index < 0) { if (!saved.disabledOpenCode[id]) throw new Error('Original plugin registration is missing.'); entries.push(saved.disabledOpenCode[id]); delete saved.disabledOpenCode[id]; }
      await this.saveDocument({id:'plugins:opencode',content:JSON.stringify(entries,null,2),revision:current.revision}); await this.saveState({...await this.readState(),disabledOpenCode:saved.disabledOpenCode});
    }
    if(tool==='codex')await this.captureSource('native:codex');if(tool==='claude')await this.captureSource('native:claude');
    this.catalogueTime=0;this.skillAuditTime=0; return {ok:true};
  }
  async toggleSkill({id,enabled}) {
    if (typeof enabled !== 'boolean') throw new Error('Enablement must be true or false.');
    const inv = await this.inventory(); const skill = inv.skills.find((s)=>s.id===id); if (!skill) throw new Error('Unknown skill.');
    skill.enabled=enabled;await this.writeLibrary(inv.skills);return {ok:true};
  }
  async syncTargets() {
    const targets = [['codex','.agents/skills'],['claude','.claude/skills'],['opencode','.config/opencode/skills']];
    for (const [id,dir] of [['pi','.pi/agent/skills/LX14-AI-Skills'],['gemini','.gemini/skills'],['copilot','.copilot/skills'],['cursor','.cursor/skills'],['grok-build','.grok/skills']]) if (TOOL_DEFINITIONS.find((t)=>t[0]===id) && (executable(TOOL_DEFINITIONS.find((t)=>t[0]===id)[4]) || existsSync(path.join(this.home,TOOL_DEFINITIONS.find((t)=>t[0]===id)[5])))) targets.push([id,dir]);
    return targets.map(([target,relative])=>({target,path:path.join(this.home,relative),source:path.join(this.data,'skills',target)}));
  }

  async nativeSkillAudit(library, force=false) {
    if(!force&&this.skillAudit&&Date.now()-this.skillAuditTime<60000)return this.skillAudit;
    const enabled=library.skills.filter((s)=>s.enabled);const expected=new Map(enabled.map((s)=>[s.path,s]));
    const result={codex:[],claude:[],opencode:[],pi:[],gemini:[],copilot:[],cursor:[]};
    let native;
    try {native=await this.codex.catalogue();if(native.warnings?.length)result.codex.push(...native.warnings);}
    catch(error){result.codex.push(error.message);native={skills:[]};}
    const found=new Set();
    for(const skill of native.skills||[])if(skill.enabled!==false&&skill.pluginEnabled!==false) {
      const file=await realpath(skill.path).catch(()=>skill.path);
      if(!expected.has(file))result.codex.push(`${skill.name}: extra native skill`);
      else if(found.has(file))result.codex.push(`${skill.name}: duplicate native skill`);else found.add(file);
    }
    for(const skill of enabled)if(!found.has(skill.path))result.codex.push(`${skill.name}: not enabled in Codex discovery`);
    const settings=jsonc(await optional(path.join(this.home,'.claude/settings.json'),'{}'));
    const installed=jsonc(await optional(path.join(this.home,'.claude/plugins/installed_plugins.json'),'{}')).plugins||{};
    const skillPlugins=[];
    for(const [id,entries] of Object.entries(installed)) {
      const entry=Array.isArray(entries)?entries.find((e)=>e.scope==='user')||entries[0]:entries;
      if(settings.enabledPlugins?.[id]===false||!entry?.installPath)continue;
      if(await this.hasSkills(path.join(entry.installPath,'skills'))||await this.hasSkills(path.join(entry.installPath,'commands'),true)) {
        result.claude.push(`${id}: enabled plugin contributes skills/commands`);skillPlugins.push(id);
      }
    }
    for(const skill of enabled)if(settings.skillOverrides?.[skill.name]==='off')result.claude.push(`${skill.name}: disabled by Claude visibility override`);
    if(settings.disableBundledSkills!==true)result.claude.push('Bundled Claude skills are not disabled');
    if(settings.skillOverrides?.doctor!=='off')result.claude.push('Claude doctor skill is not disabled');
    if(settings.syncClaudeAiSkills!==false)result.claude.push('Claude web skill sync is not disabled');
    for(const name of await this.commandNames(path.join(this.home,'.claude/commands')))if(settings.skillOverrides?.[name]!=='off')result.claude.push(`${name}: user slash command adds a skill`);
    const oc=jsonc(await optional(path.join(this.home,'.config/opencode/opencode.jsonc'),'{}'));
    if(oc.skills?.length)result.opencode.push('Additional OpenCode skill sources are configured');
    const pi=jsonc(await optional(path.join(this.home,'.pi/agent/settings.json'),'{}'));
    if((pi.packages||[]).some((p)=>typeof p==='string'||!Array.isArray(p.skills)||p.skills.length))result.pi.push('Pi package skills are not suppressed');
    if(!pi.skills?.includes('!**')||enabled.some((s)=>!pi.skills.includes(`+skills/LX14-AI-Skills/${s.name}`))||pi.skills.some((s)=>s!=='!**'&&!enabled.some((skill)=>s===`+skills/LX14-AI-Skills/${skill.name}`)))result.pi.push('Pi global skill filters do not restrict discovery to LX14-AI-Skills');
    for(const id of ['gemini','copilot','cursor'])result[id].push('Native/project skill discovery has no verified inventory adapter; shared files alone do not prove the total count');
    this.skillAudit={issues:result,native,skillPlugins};this.skillAuditTime=Date.now();return this.skillAudit;
  }
  async commandNames(directory, prefix='') {
    const names=[];
    for(const entry of await readdir(directory,{withFileTypes:true}).catch(()=>[])) {
      if(entry.isFile()&&entry.name.endsWith('.md'))names.push(prefix+entry.name.slice(0,-3));
      if(entry.isDirectory())names.push(...await this.commandNames(path.join(directory,entry.name),prefix+entry.name+':'));
    }
    return names;
  }
  async hasSkills(directory, commands=false) {
    for(const entry of await readdir(directory,{withFileTypes:true}).catch(()=>[])) {
      if(entry.isFile()&&(commands?entry.name.endsWith('.md'):entry.name==='SKILL.md'))return true;
      if(entry.isDirectory()&&await this.hasSkills(path.join(directory,entry.name),commands))return true;
    }
    return false;
  }
  async enforceNativeSkills(library, audit) {
    const expected=new Set(library.skills.filter((s)=>s.enabled).map((s)=>s.path));
    const preferences=new Map(library.skills.map((s)=>[s.path,s.enabled]));
    for(const skill of audit.native.skills||[])preferences.set(skill.path,expected.has(await realpath(skill.path).catch(()=>skill.path)));
    this.document('native:codex','Codex plugin settings','codex',path.join(this.home,'.codex/config.toml'),'config',{projection:['plugins'],parser:'toml',nativeToggleOnly:true});
    await this.codex.setLibrarySkills([...preferences].map(([path,enabled])=>({path,enabled})));
    const saved=await this.readState();
    const claudeFile=await resolvedTarget(path.join(this.home,'.claude/settings.json'));const raw=await optional(claudeFile,'{}');
    const changes=[['disableBundledSkills',true],['skillOverrides',null],['syncClaudeAiSkills',false]];
    let next=raw;
    for(const [name,value] of changes)next=applyEdits(next,modify(next,name==='skillOverrides'?['skillOverrides','doctor']:[name],name==='skillOverrides'?'off':value,{formattingOptions:{insertSpaces:true,tabSize:2}}));
    for(const skill of library.skills)next=applyEdits(next,modify(next,['skillOverrides',skill.name],skill.enabled?'on':'off',{formattingOptions:{insertSpaces:true,tabSize:2}}));
    for(const name of await this.commandNames(path.join(this.home,'.claude/commands')))next=applyEdits(next,modify(next,['skillOverrides',name],'off',{formattingOptions:{insertSpaces:true,tabSize:2}}));
    if(audit.skillPlugins.length&&saved.strictPluginConsent)for(const id of audit.skillPlugins)next=applyEdits(next,modify(next,['enabledPlugins',id],false,{formattingOptions:{insertSpaces:true,tabSize:2}}));
    this.document('native:claude','Claude plugin settings','claude',path.join(this.home,'.claude/settings.json'),'config',{projection:['enabledPlugins'],format:'json'});
    if(next!==raw)await this.atomic(claudeFile,next);
    const ocFile=await resolvedTarget(path.join(this.home,'.config/opencode/opencode.jsonc'));const ocRaw=await optional(ocFile,'{}');const oc=jsonc(ocRaw);
    if(oc.skills?.length){this.document('native:opencode-skills','OpenCode additional skill roots','opencode',path.join(this.home,'.config/opencode/opencode.jsonc'),'config',{projection:['skills'],format:'json'});await this.atomic(ocFile,applyEdits(ocRaw,modify(ocRaw,['skills'],[],{formattingOptions:{insertSpaces:true,tabSize:2}})));}
    if(existsSync(path.join(this.home,'.pi/agent/settings.json'))) {
      const file=await resolvedTarget(path.join(this.home,'.pi/agent/settings.json'));const raw=await readFile(file,'utf8');const value=jsonc(raw);
      value.packages=(value.packages||[]).map((p)=>({...typeof p==='string'?{source:p}:p,skills:[]}));value.skills=['!**',...library.skills.filter((s)=>s.enabled).map((s)=>`+skills/LX14-AI-Skills/${s.name}`)];
      this.document('native:pi','Pi settings','pi',path.join(this.home,'.pi/agent/settings.json'),'config',{projection:['skills'],format:'json'});
      if(JSON.stringify(jsonc(raw))!==JSON.stringify(value)){await this.atomic(file,JSON.stringify(value,null,2)+'\n');}
    }
    for(const id of ['native:codex','native:claude','native:opencode-skills','native:pi'])await this.captureSource(id);
    this.skillAuditTime=0;this.catalogueTime=0;
  }
  async syncPreview() {
    const library=await this.library();const entries=library.skills.filter((s)=>s.enabled);
    const targets=await this.syncTargets();
    const audit=await this.nativeSkillAudit(library,true);
    const changes=[]; const warnings=[];
    if(audit.issues.codex.some((issue)=>!issue.includes('extra native skill')&&!issue.includes('duplicate native skill')&&!issue.includes('not enabled in Codex')))throw new Error(`Cannot safely reconcile Codex: ${audit.issues.codex.join('; ')}`);
    if(audit.skillPlugins.length)warnings.push(`${audit.skillPlugins.length} Claude plugins contribute extra skills. Exact counts require disabling these plugins and their hooks: ${audit.skillPlugins.join(', ')}`);
    for (const {target:tool,path:target,source} of targets) {
      let correct=false; try { correct=(await lstat(target)).isSymbolicLink() && path.resolve(path.dirname(target),await readlink(target))===source; } catch {}
      changes.push({target:tool,action:correct?'Refresh shared catalogue':existsSync(target)?'Back up existing skills and link shared catalogue':'Link shared catalogue',path:target,source});
    }
    const extraSources=jsonc(await optional(path.join(this.home,'.config/opencode/opencode.jsonc'),'{}')).skills;
    if(extraSources?.length)warnings.push('OpenCode has additional explicit skill sources. These can override shared files; remove them for strict shared-library precedence.');
    warnings.push('Sync enforces the enabled LX14-AI-Skills set, including Codex. Native skill sources must be disabled for exact global parity. Restart agents after sync; project-scoped skills require a separate project audit.');
    const nativeConfig=[];for(const relative of ['.codex/config.toml','.claude/settings.json','.config/opencode/opencode.jsonc','.pi/agent/settings.json'])nativeConfig.push(hash(await optional(path.join(this.home,relative))));
    const snapshot = JSON.stringify({nativeConfig,nativeSkills:audit.native.skills.map((s)=>({path:s.path,enabled:s.enabled})),entries:entries.map((s)=>({name:s.name,path:s.path,pluginId:s.pluginId})),changes});
    this.syncPlan={revision:hash(snapshot),entries,changes,audit}; return {revision:this.syncPlan.revision,changes,warnings,count:entries.length};
  }
  async syncApply({revision}) {
    const before=this.syncPlan; if(!before || before.revision!==revision) throw new Error('Preview skill sharing before applying it.');
    await this.syncPreview(); if(this.syncPlan.revision!==revision) throw new Error('The catalogue changed. Review a fresh preview.');
    const plan=this.syncPlan;
    const library=await this.library();
    const saved=await this.readState();
    if(saved.syncPending||saved.nativePending) throw new Error('An interrupted sync needs recovery. Run npm run service -- restore-skills first.');
    const exported=[]; const names=new Set();
    for(const skill of plan.entries) {
      const name=skill.name.replace(/[^a-zA-Z0-9-]/g,'-');
      if(names.has(name)) throw new Error(`Duplicate exported skill name: ${name}`);
      names.add(name); exported.push({name,source:await realpath(path.dirname(skill.path)),custom:!skill.pluginId&&skill.scope!=='system'});
      await stat(skill.path);
    }
    const transaction=[]; const suffix=randomUUID();
    // Validate every destination before replacing any live root or export.
    for(const change of plan.changes) {
      const sourceInfo=await lstat(change.source).catch((e)=>{if(e.code!=='ENOENT')throw e;return null;});
      if(sourceInfo) {
        if(!sourceInfo.isDirectory() || sourceInfo.isSymbolicLink()) throw new Error('Managed export must be a directory.');
        for(const name of await readdir(change.source)) if(!(await lstat(path.join(change.source,name))).isSymbolicLink()) throw new Error('Unexpected regular file in managed export.');
      }
      const rootInfo=await lstat(change.path).catch((e)=>{if(e.code!=='ENOENT')throw e;return null;});
      const linked=rootInfo?.isSymbolicLink() && path.resolve(path.dirname(change.path),await readlink(change.path))===change.source;
      transaction.push({...change,stage:`${change.source}.stage-${suffix}`,exportPrevious:sourceInfo?`${change.source}.before-${suffix}`:null,previous:rootInfo&&!linked?`${change.path}.before-agent-hub-${suffix}`:null,replaceRoot:!linked});
    }
    const snapshots=[];
    const nativeFiles=[['native:codex','.codex/config.toml'],['native:claude','.claude/settings.json'],['native:opencode-skills','.config/opencode/opencode.jsonc'],['native:pi','.pi/agent/settings.json']];
    await this.inventory();
    for(const [id,relative] of nativeFiles) {const {target}=await this.resolveDocument(id);const doc=this.documents.get(id);snapshots.push({id,target,content:await optional(target),existed:existsSync(target),source:doc.sourcePath,sourceContent:await optional(doc.sourcePath),sourceExisted:existsSync(doc.sourcePath)});}
    const nativeBackups=[];for(const snapshot of snapshots){nativeBackups.push(await this.backup(snapshot.target,snapshot.id));nativeBackups.push(await this.backup(snapshot.source,`source:${snapshot.id}`));}
    const preserved=await this.readState();
    const completed=[];let nativeStarted=false;
    try {
      for(const c of transaction) {
        await mkdir(c.stage,{recursive:true,mode:0o700});
        for(const e of exported)await symlink(e.source,path.join(c.stage,e.name),'dir');
        await mkdir(path.dirname(c.path),{recursive:true,mode:0o700});
      }
      await this.saveState({...preserved,syncPending:transaction,nativePending:nativeBackups});
      nativeStarted=true;await this.enforceNativeSkills(library,plan.audit);
      for(const c of transaction) {
        if(c.exportPrevious) {await rename(c.source,c.exportPrevious);completed.push(()=>rename(c.exportPrevious,c.source));}
        await rename(c.stage,c.source); completed.push(()=>rm(c.source,{recursive:true,force:true}));
        if(c.replaceRoot) {
          if(c.previous) {await rename(c.path,c.previous);completed.push(()=>rename(c.previous,c.path));}
          await symlink(c.source,c.path,'dir');completed.push(()=>rm(c.path,{force:true}));
        }
      }
      const next={...preserved,sync:{count:plan.entries.length,targets:plan.changes.map((c)=>c.target),fingerprint:hash(JSON.stringify(plan.entries.map((s)=>({name:s.name,path:s.path})))),updatedAt:new Date().toISOString(),rollback:[...(saved.sync?.rollback || []),...transaction.filter((c)=>c.replaceRoot).map(({path,previous})=>({path,previous}))]}};
      await this.saveState(next);
    } catch(error) {
      try {for(const undo of completed.reverse())await undo();if(nativeStarted)for(const snapshot of snapshots) {if(snapshot.existed)await this.atomic(snapshot.target,snapshot.content);else await rm(snapshot.target,{force:true});if(snapshot.sourceExisted)await this.atomic(snapshot.source,snapshot.sourceContent);else await rm(snapshot.source,{force:true});}
        this.codex.close?.();this.skillAuditTime=0;this.catalogueTime=0;await this.saveState(preserved);}
      catch {throw new Error('Sync recovery could not finish. Backups are preserved; run npm run service -- restore-skills.');}
      throw error;
    } finally {for(const c of transaction)await rm(c.stage,{recursive:true,force:true});}
    for(const c of transaction)if(c.exportPrevious)await rm(c.exportPrevious,{recursive:true,force:true});
    return {ok:true,count:plan.entries.length};
  }

  async maintainSync() {
    const saved=await this.readState();if(!saved.sync)return;
    const library=await this.library();const fingerprint=hash(JSON.stringify(library.skills.filter((s)=>s.enabled).map((s)=>({name:s.name,path:s.path}))));
    if(fingerprint===saved.sync.fingerprint)return;
    const plan=await this.syncPreview();
    if(plan.changes.some((c)=>c.action!=='Refresh shared catalogue'))throw new Error('A shared skill root changed outside Agent Hub. Review sync before replacing it.');
    await this.syncApply({revision:plan.revision});
  }
}
