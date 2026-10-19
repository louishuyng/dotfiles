import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, writeFile, readFile, symlink, rm, readlink, readdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { Configuration, hash, jsonc } from './config.mjs';
import { allowedHost, authorized, makeApp } from './index.mjs';

async function fixture(){
  const home=await mkdtemp(path.join(tmpdir(),'agent-hub-config-')); const root=path.join(home,'.dotfiles'); const data=path.join(home,'.local/share/agent-hub');
  await mkdir(path.join(root,'ai/skills/example'),{recursive:true}); await mkdir(path.join(home,'.codex'),{recursive:true}); await mkdir(path.join(home,'.claude'),{recursive:true});await mkdir(path.join(home,'.config/opencode'),{recursive:true});
  const skill=path.join(root,'ai/skills/example/SKILL.md');await writeFile(skill,'---\nname: example\ndescription: Example skill\n---\n');
  const codex={catalogue:async()=>({skills:[{name:'example',path:skill,scope:'user',enabled:true}],plugins:[],warnings:[]}),setLibrarySkills:async()=>{},close(){}};
  const config=new Configuration({home,root,data,codex});await config.init();await config.inventory();return {home:config.home,root:config.root,data:config.data,config,codex};
}
test('projection edits preserve unrelated settings and stale edits are rejected',async()=>{
  const f=await fixture();try{
    const p=path.join(f.home,'.claude/settings.json'); await writeFile(p,'{ // preserve\n"secret":"do-not-return", "hooks": {}}');
    const d=await f.config.readDocument('hooks:claude');assert.ok(!d.content.includes('do-not-return'));
    await f.config.saveDocument({...d,content:'{"Stop":[]}'}); const saved=await readFile(p,'utf8');assert.ok(saved.includes('// preserve'));assert.equal(jsonc(saved).secret,'do-not-return');
    await assert.rejects(f.config.saveDocument({...d,content:'{}'}),/changed outside/);
    const backups=(await f.config.readState()).backups;const current=await f.config.readDocument(d.id);await f.config.restore({backupId:backups[0].id,revision:current.revision});assert.deepEqual(jsonc(await readFile(p,'utf8')).hooks,{});
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('symlinked parent cannot escape a selected project when target file is absent',async()=>{
  const f=await fixture();try{
    const project=path.join(f.home,'project');const outside=path.join(f.home,'outside');await mkdir(project);await mkdir(outside);await symlink(outside,path.join(project,'.github'));
    await f.config.selectProject({path:project}); const inv=await f.config.inventory();const doc=inv.documents.find((d)=>d.id.startsWith('project:')&&d.tool==='copilot');
    await assert.rejects(f.config.readDocument(doc.id),/outside the selected/);
    await assert.rejects(f.config.createSkill({name:'../outside',description:'bad',content:'bad'}),/skill name/);
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('sync preserves existing directory and rejects stale previews',async()=>{
  const f=await fixture();try{
    await mkdir(path.join(f.home,'.claude/skills'));await writeFile(path.join(f.home,'.claude/skills/keep.txt'),'keep');
    const plan=await f.config.syncPreview();await assert.rejects(f.config.syncApply({revision:'invalid'}),/Preview/);
    await f.config.syncApply({revision:plan.revision});assert.equal(await readlink(path.join(f.home,'.claude/skills')),path.join(f.data,'skills/claude'));
    const saved=await f.config.readState();const prior=saved.sync.rollback.find((r)=>r.path===path.join(f.home,'.claude/skills'));assert.equal(await readFile(path.join(prior.previous,'keep.txt'),'utf8'),'keep');
    assert.equal(saved.sync.count,1);
    let checks=(await f.config.inventory()).sync.checks;assert.ok(checks.every(c=>c.matched===1));assert.ok(checks.filter(c=>['codex','claude','opencode'].includes(c.target)).every(c=>c.status==='synced'));assert.ok(checks.some(c=>c.target==='codex'));
    await writeFile(path.join(f.data,'skills/claude','extra.txt'),'unexpected');checks=(await f.config.inventory()).sync.checks;assert.equal(checks.find(c=>c.target==='claude').status,'drift');
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('mutation authentication rejects DNS rebinding, cross-origin and absent tokens',()=>{
  const token='abcd';assert.ok(allowedHost('agent-hub.localhost:1355'));assert.equal(allowedHost('evil.example'),false);
  const request={headers:{host:'agent-hub.localhost:1355',origin:'http://agent-hub.localhost:1355','x-agent-hub-token':token}};
  assert.ok(authorized(request,token));assert.equal(authorized({...request,headers:{...request.headers,origin:'https://evil.example'}},token),false);assert.equal(authorized({...request,headers:{...request.headers,'x-agent-hub-token':''}},token),false);
});
test('HTTP API supplies real inventory and blocks unauthorized writes',async()=>{
  const f=await fixture();const app=await makeApp({...f});
  await new Promise((resolve)=>app.server.listen(0,'127.0.0.1',resolve));const base=`http://127.0.0.1:${app.server.address().port}`;
  try{
    const state=await fetch(`${base}/api/state`).then((r)=>r.json());assert.equal(state.skills.length,1);assert.ok(state.tools.some((t)=>t.id==='grok'&&t.subscription==='SuperGrok'));
    const response=await fetch(`${base}/api/skills/create`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({name:'unsafe'})});assert.equal(response.status,403);
    const create=await fetch(`${base}/api/skills/create`,{method:'POST',headers:{'content-type':'application/json','x-agent-hub-token':state.token,origin:base},body:JSON.stringify({name:'new-skill',description:'Useful',content:'Do this.'})});assert.equal(create.status,200);assert.ok((await readFile(path.join(f.root,'ai/skills/new-skill/SKILL.md'),'utf8')).includes('Do this.'));
  }finally{await new Promise((resolve)=>app.server.close(resolve));await rm(f.home,{recursive:true,force:true});}
});

test('plugin toggles preserve configuration symlinks and TOML errors conceal source',async()=>{
  const f=await fixture();try {
    const source=path.join(f.root,'claude.json');const live=path.join(f.home,'.claude/settings.json');
    await writeFile(source,'{"enabledPlugins":{},"private":"secret"}');await symlink(source,live);
    const registry=path.join(f.home,'.claude/plugins');await mkdir(registry);await writeFile(path.join(registry,'installed_plugins.json'),' {"plugins":{"test@market":[{"scope":"user"}]}}');
    await f.config.togglePlugin({tool:'claude',id:'test@market',enabled:false});assert.equal(await readlink(live),source);assert.equal(jsonc(await readFile(source,'utf8')).enabledPlugins['test@market'],false);
    await writeFile(path.join(f.home,'.codex/config.toml'),'token = "FAKE-PRIVATE-TOKEN"\n[plugins\n');
    await assert.rejects(f.config.readDocument('native:codex'),(error)=>!error.message.includes('FAKE-PRIVATE-TOKEN')&&/syntax is invalid/.test(error.message));
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('sync validates all exports before changes and reverses swaps after commit failure',async()=>{
  const f=await fixture();try {
    const live=path.join(f.home,'.claude/skills');await mkdir(live);await writeFile(path.join(live,'keep.txt'),'keep');
    const bad=path.join(f.data,'skills/opencode');await mkdir(path.dirname(bad),{recursive:true});await symlink(live,bad);
    let plan=await f.config.syncPreview();await assert.rejects(f.config.syncApply({revision:plan.revision}),/Managed export must be a directory/);assert.equal(await readFile(path.join(live,'keep.txt'),'utf8'),'keep');assert.equal((await f.config.readState()).sync,undefined);
    await rm(bad);await mkdir(bad);await writeFile(path.join(bad,'unexpected'),'keep');
    const nativeFile=path.join(f.home,'.claude/settings.json');const original=' {"hooks":{},"private":"keep-private"}';await writeFile(nativeFile,original);plan=await f.config.syncPreview();
    const save=f.config.saveState.bind(f.config);f.config.saveState=async(value)=>{if(value.sync&&!value.syncPending)throw new Error('fixture commit failure');return save(value);};
    await assert.rejects(f.config.syncApply({revision:plan.revision}),/fixture commit failure/);assert.equal(await readFile(path.join(live,'keep.txt'),'utf8'),'keep');assert.equal((await f.config.readState()).syncPending,undefined);assert.equal(await readFile(path.join(bad,'unexpected'),'utf8'),'keep');assert.equal(await readFile(nativeFile,'utf8'),original);assert.equal((await f.config.readState()).nativePending,undefined);
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('sync preserves real files and skill directories added to a managed export',async()=>{
  const f=await fixture();try {
    let plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});
    const source=path.join(f.data,'skills/claude');
    await writeFile(path.join(source,'notes.txt'),'keep notes');
    await mkdir(path.join(source,'herdr-projects'));await writeFile(path.join(source,'herdr-projects/SKILL.md'),'keep skill');
    plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});
    assert.deepEqual(await readdir(source),['example']);
    assert.equal(await readlink(path.join(source,'example')),path.join(f.root,'ai/skills/example'));
    const backups=(await readdir(path.dirname(source))).filter(name=>name.startsWith('claude.before-'));
    assert.equal(backups.length,1);const backup=path.join(path.dirname(source),backups[0]);
    assert.equal(await readFile(path.join(backup,'notes.txt'),'utf8'),'keep notes');
    assert.equal(await readFile(path.join(backup,'herdr-projects/SKILL.md'),'utf8'),'keep skill');
    plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});
    assert.deepEqual((await readdir(path.dirname(source))).filter(name=>name.startsWith('claude.before-')),backups);
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('repository manifest owns the exact set and Codex extras are independently disabled',async()=>{
  const f=await fixture();try {
    const extra=path.join(f.home,'.codex/plugin-extra/SKILL.md');await mkdir(path.dirname(extra),{recursive:true});await writeFile(extra,'extra');
    const example=path.join(f.root,'ai/skills/example/SKILL.md');let native=[{name:'example',path:example,enabled:true},{name:'vendor:extra',path:extra,enabled:true}];let prefs;
    f.codex.catalogue=async({includeSkills=true}={})=>({skills:includeSkills?native:[],plugins:[],warnings:[]});
    f.codex.setLibrarySkills=async(value)=>{prefs=value;native=native.map(s=>({...s,enabled:value.find(p=>p.path===s.path)?.enabled??s.enabled}));};
    await f.config.createSkill({name:'second',description:'Second skill',content:'Useful.'});
    const second=path.join(f.root,'ai/skills/second/SKILL.md');native.push({name:'second',path:second,enabled:true});
    let inv=await f.config.inventory();assert.deepEqual(inv.skills.map(s=>s.name),['example','second']);assert.equal(inv.library.name,'LX14-AI-Skills');
    await f.config.toggleSkill({id:inv.skills.find(s=>s.name==='second').id,enabled:false});
    const plan=await f.config.syncPreview();assert.equal(plan.count,1);assert.ok(plan.changes.some(c=>c.target==='codex'));await f.config.syncApply({revision:plan.revision});
    assert.equal(prefs.find(p=>p.path===extra).enabled,false);assert.equal(prefs.find(p=>p.path===second).enabled,false);
    inv=await f.config.inventory();assert.equal(inv.sync.checks.find(c=>c.target==='codex').status,'synced');
    const fs=await import('node:fs/promises');for(const target of await f.config.syncTargets())assert.deepEqual(await fs.readdir(target.path),['example']);
    native.push({name:'updated-plugin:extra',path:extra,enabled:true});f.config.skillAuditTime=0;
    assert.equal((await f.config.inventory()).sync.checks.find(c=>c.target==='codex').status,'drift');
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('setup removes only disabled library folders and preserves a recovery copy',async()=>{
  const f=await fixture();try {
    const {setup}=await import('../scripts/setup.mjs');
    await f.config.createSkill({name:'disabled',description:'Unused',content:'Preserve this.'});
    const inv=await f.config.inventory();await f.config.toggleSkill({id:inv.skills.find(s=>s.name==='disabled').id,enabled:false});
    const result=await setup(f.config);assert.equal(result.count,1);assert.ok(result.recovery.startsWith(f.data));
    assert.ok((await readFile(path.join(result.recovery,'disabled/SKILL.md'),'utf8')).includes('Preserve this.'));
    assert.equal((await f.config.inventory()).skills.length,1);
    const rerun=await setup(f.config);assert.equal(rerun.recovery,undefined);assert.equal(rerun.count,1);
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('eleven enabled repository skills produce exactly eleven links including Codex',async()=>{
  const f=await fixture();try {
    for(let i=1;i<=10;i++)await f.config.createSkill({name:`skill-${i}`,description:'Required skill',content:'Use this.'});
    const library=await f.config.library();let native=library.skills.map(s=>({...s,enabled:true}));
    f.codex.catalogue=async({includeSkills=true}={})=>({skills:includeSkills?native:[],plugins:[],warnings:[]});
    f.codex.setLibrarySkills=async(values)=>{native=native.map(s=>({...s,enabled:values.find(v=>v.path===s.path)?.enabled??s.enabled}));};
    const plan=await f.config.syncPreview();assert.equal(plan.count,11);await f.config.syncApply({revision:plan.revision});
    const fs=await import('node:fs/promises');for(const target of await f.config.syncTargets())assert.equal((await fs.readdir(target.path)).length,11);
    const codex=(await f.config.inventory()).sync.checks.find(c=>c.target==='codex');assert.equal(codex.matched,11);assert.equal(codex.expected,11);assert.equal(codex.status,'synced');
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('Claude coupled plugin suppression requires explicit strict consent',async()=>{
  const f=await fixture();try {
    const plugin=path.join(f.home,'.claude/plugins/vendor');await mkdir(path.join(plugin,'skills/extra'),{recursive:true});await writeFile(path.join(plugin,'skills/extra/SKILL.md'),'extra');
    await writeFile(path.join(f.home,'.claude/plugins/installed_plugins.json'),JSON.stringify({plugins:{'vendor@market':[{scope:'user',installPath:plugin}]}}));
    await writeFile(path.join(f.home,'.claude/settings.json'),JSON.stringify({enabledPlugins:{'vendor@market':true},hooks:{Stop:[]},skillOverrides:{example:'off'}}));
    await mkdir(path.join(f.home,'.claude/commands'));await writeFile(path.join(f.home,'.claude/commands/implement.md'),'Implement this.');
    assert.ok((await f.config.nativeSkillAudit(await f.config.library(),true)).issues.claude.some(issue=>issue.includes('example: disabled')));
    let plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});
    let value=jsonc(await readFile(path.join(f.home,'.claude/settings.json'),'utf8'));assert.equal(value.enabledPlugins['vendor@market'],true);assert.equal(value.skillOverrides.implement,'off');assert.equal(value.skillOverrides.example,'on');assert.deepEqual(value.hooks,{Stop:[]});
    assert.equal((await f.config.inventory()).sync.checks.find(c=>c.target==='claude').status,'drift');
    await f.config.saveState({...await f.config.readState(),strictPluginConsent:true});plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});
    value=jsonc(await readFile(path.join(f.home,'.claude/settings.json'),'utf8'));assert.equal(value.enabledPlugins['vendor@market'],false);assert.deepEqual(value.hooks,{Stop:[]});
    assert.equal((await f.config.inventory()).sync.checks.find(c=>c.target==='claude').status,'synced');
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('failed native preview preserves disabled source folders',async()=>{
  const f=await fixture();try {
    const {setup}=await import('../scripts/setup.mjs');await f.config.createSkill({name:'disabled',description:'Unused',content:'Keep it.'});
    const inv=await f.config.inventory();await f.config.toggleSkill({id:inv.skills.find(s=>s.name==='disabled').id,enabled:false});
    f.codex.catalogue=async()=>{throw new Error('Codex unavailable');};
    await assert.rejects(setup(f.config),/Cannot safely reconcile Codex/);assert.ok((await readFile(path.join(f.root,'ai/skills/disabled/SKILL.md'),'utf8')).includes('Keep it.'));assert.equal((await f.config.readState()).prunePending,undefined);
  }finally{await rm(f.home,{recursive:true,force:true});}
});
test('Pi settings projection conceals unrelated fields and native edits invalidate audit',async()=>{
  const f=await fixture();try {
    const pi=path.join(f.home,'.pi/agent');await mkdir(pi,{recursive:true});await writeFile(path.join(pi,'settings.json'),' {"skills":[],"private":"FAKE-PRIVATE"}');
    await f.config.inventory();assert.ok(!(await f.config.readDocument('native:pi')).content.includes('FAKE-PRIVATE'));
    const plan=await f.config.syncPreview();await f.config.syncApply({revision:plan.revision});await f.config.inventory();assert.ok(f.config.skillAuditTime>0);
    const doc=await f.config.readDocument('native:opencode-skills');await f.config.saveDocument({...doc,content:'["additional-root"]'});assert.equal(f.config.skillAuditTime,0);
    const check=(await f.config.inventory()).sync.checks.find(c=>c.target==='opencode');assert.equal(check.status,'drift');
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('skill recovery preflights roots and resumes a crash after restoring a root',async()=>{
  const f=await fixture();try {
    const {restoreSkills}=await import('../scripts/service.mjs');const fs=await import('node:fs/promises');
    const roots=[];
    for(const name of ['first','second']) {
      const live=path.join(f.home,name);const previous=live+'.original';const source=path.join(f.data,'skills',name);await mkdir(source,{recursive:true});await mkdir(previous);await writeFile(path.join(previous,'original'),'keep');await symlink(source,live);roots.push({path:live,previous});
    }
    await f.config.saveState({sync:{rollback:roots}});await rm(roots[0].path);await mkdir(roots[0].path);
    await assert.rejects(restoreSkills({...f,app:path.join(f.root,'ai/agent-hub')}),/changed skill root/);assert.ok((await fs.lstat(roots[1].path)).isSymbolicLink());
    await rm(roots[0].path,{recursive:true});await symlink(path.join(f.data,'skills/first'),roots[0].path);
    await rm(roots[1].path);await fs.rename(roots[1].previous,roots[1].path);await f.config.saveState({sync:{rollback:roots},restorePending:roots[1]});
    await restoreSkills({...f,app:path.join(f.root,'ai/agent-hub')});for(const root of roots)assert.equal(await readFile(path.join(root.path,'original'),'utf8'),'keep');
    assert.equal((await f.config.readState()).sync,undefined);assert.equal((await f.config.readState()).restorePending,undefined);
    await restoreSkills({...f,app:path.join(f.root,'ai/agent-hub')});
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('global UI configuration lives in ai and mirrors hooks without exporting private fields',async()=>{
  const f=await fixture();try {
    const settings=path.join(f.home,'.claude/settings.json');await writeFile(settings,'{ // retain comment\n"private":"FAKE-PRIVATE", "hooks":{"Stop":[]}}');
    await rm(path.join(f.root,'ai/hooks/claude.json'),{force:true});
    await writeFile(path.join(f.root,'ai/AGENTS.md'),'Shared instructions.');
    await f.config.configureGlobals();
    const inv=await f.config.inventory();assert.ok(inv.documents.filter(d=>!d.id.startsWith('project:')).every(d=>d.path.startsWith(path.join(f.root,'ai')+path.sep)));
    for(const file of ['.codex/AGENTS.md','.claude/CLAUDE.md','.config/opencode/AGENTS.md'])assert.equal(await readlink(path.join(f.home,file)),path.join(f.root,'ai/AGENTS.md'));
    const hook=await f.config.readDocument('hooks:claude');assert.equal(hook.path,path.join(f.root,'ai/hooks/claude.json'));assert.ok(!hook.content.includes('FAKE-PRIVATE'));
    await f.config.saveDocument({...hook,content:'{"SessionStart":[]}'});
    assert.deepEqual(jsonc(await readFile(hook.path,'utf8')),{SessionStart:[]});const runtime=await readFile(settings,'utf8');assert.ok(runtime.includes('// retain comment'));assert.equal(jsonc(runtime).private,'FAKE-PRIVATE');assert.deepEqual(jsonc(runtime).hooks,{SessionStart:[]});
    await writeFile(hook.path,'{"Stop":[]}');await f.config.configureGlobals();assert.deepEqual(jsonc(await readFile(settings,'utf8')).hooks,{Stop:[]});
    const outside=path.join(f.home,'private.json');await writeFile(outside,'PRIVATE');await rm(hook.path);await symlink(outside,hook.path);await assert.rejects(f.config.readDocument(hook.id),/real files inside/);
  }finally{await rm(f.home,{recursive:true,force:true});}
});

test('invalid global source leaves the API available with a repair warning',async()=>{
  const f=await fixture();let app;try {
    await writeFile(path.join(f.root,'ai/hooks/claude.json'),'broken JSON');app=await makeApp({...f});
    await new Promise(resolve=>app.server.listen(0,'127.0.0.1',resolve));const base=`http://127.0.0.1:${app.server.address().port}`;
    const state=await fetch(`${base}/api/state`).then(r=>r.json());assert.ok(state.token);assert.ok(state.warnings.some(w=>w.includes('Global configuration:')));
    const doc=await fetch(`${base}/api/document?id=hooks:claude`).then(r=>r.json());assert.equal(doc.content,'broken JSON');
  }finally{if(app)await new Promise(resolve=>app.server.close(resolve));await rm(f.home,{recursive:true,force:true});}
});
