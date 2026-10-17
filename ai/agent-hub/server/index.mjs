import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { homedir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { randomBytes, timingSafeEqual } from 'node:crypto';
import path from 'node:path';
import { CodexClient } from './codex.mjs';
import { Configuration, executable } from './config.mjs';
import { UsageIndex } from './usage.mjs';
import { SharedSetup } from './shared.mjs';

const run = promisify(execFile);
export function allowedHost(value) { try { return ['agent-hub.localhost','127.0.0.1','localhost','[::1]'].includes(new URL(`http://${value}`).hostname); } catch { return false; } }
export function authorized(req, token) {
  if (!allowedHost(req.headers.host)) return false;
  let origin; try { origin = new URL(req.headers.origin); } catch { return false; }
  if (!['http:','https:'].includes(origin.protocol) || origin.host !== req.headers.host || !allowedHost(origin.host)) return false;
  const supplied = Buffer.from(String(req.headers['x-agent-hub-token'] || ''));
  return supplied.length === token.length && timingSafeEqual(supplied, Buffer.from(token));
}
async function body(req) {
  const chunks = []; let size = 0;
  for await (const chunk of req) { size += chunk.length; if (size > 3 * 1024 * 1024) throw new Error('Request exceeds the 3 MB limit.'); chunks.push(chunk); }
  if (!req.headers['content-type']?.startsWith('application/json')) throw new Error('Send JSON configuration data.');
  let data; try { data = JSON.parse(Buffer.concat(chunks).toString()); } catch { throw new Error('Request contains invalid JSON.'); }
  if (!data || Array.isArray(data) || typeof data !== 'object') throw new Error('Expected a JSON object.'); return data;
}
function reply(res,status,value) { res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}); res.end(JSON.stringify(value)); }
export async function makeApp({home=homedir(),root=fileURLToPath(new URL('../../..',import.meta.url)),data=path.join(home,'.local/share/agent-hub'),codex}={}) {
  const token = randomBytes(32).toString('hex');
  const client = codex || new CodexClient({home,cwd:home,executable:executable('codex') || 'codex'});
  const config = new Configuration({home,root,data,codex:client}); await config.init();
  const shared = new SharedSetup(config); let globalWarning='';
  try { await config.inventory(); await shared.recover(); await config.configureGlobals(); await shared.reconcile(); await config.maintainSync(); } catch(error){globalWarning=error.message;}
  const usage = new UsageIndex(home,path.join(data,'cache'));
  const dist = fileURLToPath(new URL('../dist',import.meta.url)); let mutation=Promise.resolve();
  const service = async () => {
    const installed = await stat(path.join(home,'Library/LaunchAgents/dev.agent-hub.plist')).then(()=>true,()=>false);
    const running = installed && await run('/bin/launchctl',['print',`gui/${process.getuid()}/dev.agent-hub`],{timeout:2000}).then((r)=>/state = running/.test(r.stdout),()=>false);
    const saved = await config.readState(); return {installed,running,url:saved.serviceUrl || 'http://agent-hub.localhost:1355',logPath:path.join(data,'logs')};
  };
  const handlers = {
    'document/save': (value)=>config.saveDocument(value),
    'document/restore': (value)=>config.restore(value),
    'skills/create': async(value)=>{await config.createSkill(value);await config.maintainSync({activate:true});return {ok:true};},
    'skills/toggle': async(value)=>{await config.toggleSkill(value);await config.maintainSync({activate:true});return {ok:true};},
    'plugins/toggle': async(value)=>{await config.togglePlugin(value); if((await config.readState()).sync) {const p=await config.syncPreview();await config.syncApply({revision:p.revision});}return {ok:true};},
    'project/select': (value)=>config.selectProject(value),
    'sync/preview': ()=>config.syncPreview(),
    'sync/apply': (value)=>config.syncApply(value),
    'shared/save': (value)=>shared.save(value),
    'shared/import': (value)=>shared.import(value),
    'shared/sync': ()=>shared.reconcile(),
  };
  let syncWarning='';
  const maintenance=setInterval(()=>{mutation=mutation.then(async()=>{await shared.recover();await config.configureGlobals();await shared.reconcile();await config.maintainSync();}).then(()=>{syncWarning='';globalWarning='';}).catch((error)=>{syncWarning=error.message;});},60000);maintenance.unref();
  const server = createServer(async(req,res)=>{
    try {
      if(!allowedHost(req.headers.host)) {reply(res,403,{error:'Agent Hub accepts only local requests.'});return;}
      const url=new URL(req.url,`http://${req.headers.host}`);
      res.setHeader('Content-Security-Policy',"default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self'; connect-src 'self'; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'");
      res.setHeader('Referrer-Policy','no-referrer');res.setHeader('X-Frame-Options','DENY');
      if(url.pathname.startsWith('/api/')) {
        if(req.method==='GET') {
          if(url.pathname==='/api/state') {const state=await config.inventory();if(syncWarning)state.warnings.push(syncWarning);if(globalWarning)state.warnings.push(`Global configuration: ${globalWarning}`);reply(res,200,{...state,token,service:await service()});return;}
          if(url.pathname==='/api/usage') {reply(res,200,await usage.report(url.searchParams));return;}
          if(url.pathname==='/api/document') {reply(res,200,await config.readDocument(url.searchParams.get('id')));return;}
          if(url.pathname==='/api/shared') {reply(res,200,await shared.snapshot());return;}
          if(url.pathname==='/api/health') {reply(res,200,{ok:true,service:await service()});return;}
        }
        if(req.method==='POST') {
          if(!authorized(req,token)) {reply(res,403,{error:'This request needs a same-origin Agent Hub session. Refresh the page.'});return;}
          const handler=handlers[url.pathname.slice(5)]; if(!handler){reply(res,404,{error:'Unknown action.'});return;}
          const data=await body(req); const task=mutation.then(()=>handler(data)); mutation=task.catch(()=>{}); reply(res,200,await task);return;
        }
        reply(res,404,{error:'Unknown endpoint.'});return;
      }
      if(req.method!=='GET' && req.method!=='HEAD') {reply(res,405,{error:'Method not supported.'});return;}
      const relative=decodeURIComponent(url.pathname).replace(/^\//,'');let file=path.resolve(dist,relative || 'index.html');
      if(!file.startsWith(`${dist}${path.sep}`)) {reply(res,403,{error:'Invalid path.'});return;}
      try {if(!(await stat(file)).isFile())file=path.join(dist,'index.html');} catch {if(path.extname(file)){reply(res,404,{error:'File not found.'});return;}file=path.join(dist,'index.html');}
      const mime={'.html':'text/html; charset=utf-8','.js':'application/javascript','.css':'text/css','.svg':'image/svg+xml','.png':'image/png','.woff2':'font/woff2'};
      const content=await readFile(file);res.writeHead(200,{'Content-Type':mime[path.extname(file)] || 'application/octet-stream','X-Content-Type-Options':'nosniff','Cache-Control':file.endsWith('index.html')?'no-cache':'public, max-age=3600'});res.end(req.method==='HEAD'?undefined:content);
    } catch(error) {reply(res,error.code==='ENOENT'?404:400,{error:error.message || 'The operation failed. Check Agent Hub logs.'});}
  });
  server.on('close',()=>{clearInterval(maintenance);client.close?.();usage.db?.close();}); return {server,config,usage,token};
}
if(process.argv[1]===fileURLToPath(import.meta.url)) {
  const app=await makeApp(); const port=Number(process.env.PORT || 4310);
  app.server.listen(port,'127.0.0.1',()=>console.log(`Agent Hub listening on 127.0.0.1:${port}`));
  for(const signal of ['SIGTERM','SIGINT']) process.on(signal,()=>app.server.close(()=>process.exit(0)));
}
