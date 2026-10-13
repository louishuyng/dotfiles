import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, writeFile, appendFile, rm, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { consume, emptyFile, fileEvents, tokens, localDate, weekOf, UsageIndex } from './usage.mjs';

test('cache is included once and reasoning is an output subset',()=>{
  assert.deepEqual(tokens({input_tokens:100,cached_input_tokens:40,output_tokens:20,reasoning_output_tokens:5},'codex'),{input:100,cacheRead:40,cacheWrite:0,output:20,reasoning:5});
  assert.equal(tokens({input_tokens:60,cache_read_input_tokens:40,cache_creation_input_tokens:10},'claude').input,110);
});
test('Codex canonical responses replace duplicate cumulative telemetry',()=>{
  const s=emptyFile('codex','s');const timestamp='2026-10-13T00:00:00Z';
  consume(s,{timestamp,type:'event_msg',payload:{type:'token_count',info:{total_token_usage:{input_tokens:100,output_tokens:20}}}});
  consume(s,{timestamp,type:'token_usage_record',payload:{response_id:'r',usage:{input_tokens:100,output_tokens:20}}});
  consume(s,{timestamp,type:'token_usage_record',payload:{response_id:'r',usage:{input_tokens:100,output_tokens:20}}});
  assert.equal(fileEvents(s).reduce((n,e)=>n+e.input+e.output,0),120);
});
test('Codex keeps earlier legacy usage when newer canonical accounting begins',()=>{
  const state=emptyFile('codex','mixed');
  consume(state,{timestamp:'2026-10-12T00:00:00Z',ordinal:1,type:'event_msg',payload:{type:'token_count',info:{total_token_usage:{input_tokens:100,output_tokens:20},last_token_usage:{input_tokens:100}}}});
  consume(state,{timestamp:'2026-10-13T00:00:00Z',ordinal:2,type:'token_usage_record',payload:{response_id:'new',usage:{input_tokens:50,output_tokens:10}}});
  consume(state,{timestamp:'2026-10-13T00:00:01Z',ordinal:3,type:'event_msg',payload:{type:'token_count',info:{total_token_usage:{input_tokens:150,output_tokens:30},last_token_usage:{input_tokens:50}}}});
  assert.equal(fileEvents(state).reduce((n,e)=>n+e.input+e.output,0),180);
  assert.equal(state.context,50);
  assert.equal(state.peakContext,100);
});
test('Claude streaming messages and repeated tool blocks count once',()=>{
  const s=emptyFile('claude','s');const timestamp='2026-10-13T00:00:00Z';
  for(const output of [5,20,10]) consume(s,{type:'assistant',timestamp,message:{id:'same',model:'sonnet',usage:{input_tokens:80,output_tokens:output},content:[{type:'tool_use',id:'tool1'}]}});
  const events=fileEvents(s);assert.equal(events.reduce((n,e)=>n+e.output,0),20);assert.equal(events.reduce((n,e)=>n+e.toolCalls,0),1);
});
test('dates use local timezone and weeks begin on Monday',()=>{
  assert.equal(localDate('2026-10-12T18:00:00Z','Asia/Ho_Chi_Minh'),'2026-10-13');
  assert.equal(weekOf('2026-10-18'),'2026-10-12');
});
test('incremental index waits for complete lines, survives truncation, deduplicates response IDs',async()=>{
  const root=await mkdtemp(path.join(tmpdir(),'agent-hub-usage-'));const source=path.join(root,'.codex/sessions');await mkdir(source,{recursive:true});
  const file=path.join(source,'s.jsonl');const timestamp=new Date().toISOString();
  const usage={timestamp,type:'token_usage_record',payload:{response_id:'r',usage:{input_tokens:100,output_tokens:20}}};
  const serialized=JSON.stringify(usage);await writeFile(file,serialized.slice(0,20));
  const index=new UsageIndex(root,path.join(root,'cache'));
  try {
    let report=await index.report(new URLSearchParams({days:'7'}));assert.equal(report.summary.tokens,0);assert.equal(report.daily.length,7);assert.ok(report.daily.every((d)=>d.total===0));
    await appendFile(file,serialized.slice(20)+'\n');index.refreshedAt=null;report=await index.report(new URLSearchParams({days:'7'}));assert.equal(report.summary.tokens,120);
    await appendFile(file,serialized+'\n');index.refreshedAt=null;report=await index.report(new URLSearchParams({days:'7'}));assert.equal(report.summary.tokens,120);
    await writeFile(file,JSON.stringify({...usage,payload:{response_id:'new',usage:{input_tokens:1,output_tokens:1}}})+'\n');index.refreshedAt=null;report=await index.report(new URLSearchParams({days:'7'}));assert.equal(report.summary.tokens,2);
  } finally {index.db.close();await rm(root,{recursive:true,force:true});}
});
test('parent and two Claude sidechains contribute distinct sessions after old cache rebuild',async()=>{
  const root=await mkdtemp(path.join(tmpdir(),'agent-hub-sidechains-'));const source=path.join(root,'.claude/projects/project');const cache=path.join(root,'cache');
  await mkdir(source,{recursive:true});await mkdir(cache);
  const timestamp=new Date().toISOString();const paths=[];
  for(const [name,input,agentId] of [['parent',100,null],['first',20,'first-agent'],['second',30,'second-agent']]) {
    const file=path.join(source,`${name}.jsonl`);paths.push(file);
    await writeFile(file,JSON.stringify({type:'assistant',timestamp,sessionId:'parent-session',isSidechain:!!agentId,agentId,message:{id:`response-${name}`,model:'sonnet',usage:{input_tokens:input,output_tokens:1}}})+'\n');
  }
  const stale=new DatabaseSync(path.join(cache,'usage.sqlite'));
  stale.exec('CREATE TABLE files (path TEXT PRIMARY KEY, size INTEGER, mtime REAL, offset INTEGER, data TEXT); CREATE TABLE keep (value TEXT);');
  stale.prepare('INSERT INTO keep VALUES (?)').run('preserve');
  for(const file of paths) {const info=await stat(file);stale.prepare('INSERT INTO files VALUES (?,?,?,?,?)').run(file,info.size,info.mtimeMs,info.size,JSON.stringify({...emptyFile('claude','parent-session'),subagent:true}));}
  stale.close();
  const index=new UsageIndex(root,cache);
  try {
    const report=await index.report(new URLSearchParams({days:'7',agent:'claude'}));
    assert.equal(report.summary.tokens,153);assert.equal(report.summary.sessions,3);
    assert.deepEqual(report.sessions.map((s)=>s.id).sort(),['parent-session','subagent:first-agent','subagent:second-agent']);
    assert.equal(index.db.prepare('PRAGMA user_version').get().user_version,1);
    assert.equal(index.db.prepare('SELECT value FROM keep').get().value,'preserve');
  } finally {index.db?.close();await rm(root,{recursive:true,force:true});}
});
test('OpenCode normalizes stored JSON and message object model IDs with peak input context',async()=>{
  const root=await mkdtemp(path.join(tmpdir(),'agent-hub-opencode-'));const directory=path.join(root,'.local/share/opencode');await mkdir(directory,{recursive:true});
  const db=new DatabaseSync(path.join(directory,'opencode.db'));const timestamp=Date.now();
  db.exec('CREATE TABLE session_v2 (id TEXT, directory TEXT, parent_id TEXT, agent TEXT, model TEXT, time_created INTEGER, time_updated INTEGER); CREATE TABLE session_message (id TEXT,session_id TEXT,type TEXT,time_created INTEGER,data TEXT);');
  db.prepare('INSERT INTO session_v2 VALUES (?,?,?,?,?,?,?)').run('s','/project',null,'build',JSON.stringify({id:'stored-model',providerID:'provider'}),timestamp,timestamp+1);
  db.prepare('INSERT INTO session_v2 VALUES (?,?,?,?,?,?,?)').run('stored-only','/project',null,'build',JSON.stringify({id:'stored-model',providerID:'provider'}),timestamp,timestamp+1);
  db.prepare('INSERT INTO session_message VALUES (?,?,?,?,?)').run('low','s','assistant',timestamp+1,JSON.stringify({model:{id:'message-model'},tokens:{input:20,output:2}}));
  db.prepare('INSERT INTO session_message VALUES (?,?,?,?,?)').run('high','s','assistant',timestamp,JSON.stringify({model:{id:'message-model'},tokens:{input:90,output:10,cache:{read:10}},cost:0.1}));
  db.close();
  const index=new UsageIndex(root,path.join(root,'cache'));
  try {
    const sessions=await index.openCode();assert.equal(sessions[0].model,'message-model');assert.equal(sessions[0].context,20);assert.equal(sessions[0].peakContext,100);assert.equal(sessions[1].model,'stored-model');
    const report=await index.report(new URLSearchParams({days:'7',agent:'opencode'}));assert.equal(report.summary.tokens,132);assert.ok(report.models.includes('message-model'));assert.ok(!report.models.some((m)=>m.startsWith('{')));
  } finally {index.db?.close();await rm(root,{recursive:true,force:true});}
});
test('invalid calendar dates and excessive ranges fail before history indexing',async()=>{
  const root=await mkdtemp(path.join(tmpdir(),'agent-hub-dates-'));const index=new UsageIndex(root,path.join(root,'cache'));
  try {
    for(const query of [{to:'not-a-date'},{to:'2026-02-30'},{from:'2026-02-30',to:'2026-03-01'},{from:'2026-01-02',to:'2026-01-01'},{from:'2025-01-01',to:'2026-01-02'}]) await assert.rejects(index.report(new URLSearchParams(query)),/valid date range/);
    assert.equal(index.db,undefined);
  } finally {await rm(root,{recursive:true,force:true});}
});

test('unchanged oversized histories retain warnings and retry after file repair',async()=>{
  const root=await mkdtemp(path.join(tmpdir(),'agent-hub-large-'));const source=path.join(root,'.pi/agent/sessions');await mkdir(source,{recursive:true});const file=path.join(source,'large.jsonl');await writeFile(file,'x'.repeat(17*1024*1024));const index=new UsageIndex(root,path.join(root,'cache'));
  try {
    await index.index();assert.equal(index.db.prepare('SELECT COUNT(*) AS n FROM failures').get().n,1);await index.index();assert.ok(index.warnings.some(w=>w.includes('Oversized history record')));
    await writeFile(file,JSON.stringify({type:'session',id:'repaired',cwd:root,timestamp:new Date().toISOString()})+'\n');await index.index();assert.equal(index.db.prepare('SELECT COUNT(*) AS n FROM failures').get().n,0);assert.ok(!index.warnings.some(w=>w.includes('Oversized history record')));
  }finally{index.db?.close();await rm(root,{recursive:true,force:true});}
});
