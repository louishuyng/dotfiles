import { execFileSync } from 'node:child_process';
import { mkdir, writeFile, readFile, rm, realpath, lstat, readlink, rename, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { executable } from '../server/config.mjs';

const home=homedir();const app=fileURLToPath(new URL('..',import.meta.url));
const directory=path.join(home,'Library/LaunchAgents');const data=path.join(home,'.local/share/agent-hub');const logs=path.join(data,'logs');
const domain=`gui/${process.getuid()}`;const labels=['dev.agent-hub.proxy','dev.agent-hub'];
const xml=(value)=>String(value).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
export function plist(label,args,workingDirectory,env,logDirectory) {
  return `<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict>\n<key>Label</key><string>${xml(label)}</string>\n<key>ProgramArguments</key><array>${args.map((a)=>`<string>${xml(a)}</string>`).join('')}</array>\n<key>WorkingDirectory</key><string>${xml(workingDirectory)}</string>\n<key>EnvironmentVariables</key><dict>${Object.entries(env).map(([k,v])=>`<key>${xml(k)}</key><string>${xml(v)}</string>`).join('')}</dict>\n<key>RunAtLoad</key><true/><key>KeepAlive</key><true/><key>ThrottleInterval</key><integer>10</integer>\n<key>ProcessType</key><string>Background</string>\n<key>StandardOutPath</key><string>${xml(path.join(logDirectory,`${label}.log`))}</string>\n<key>StandardErrorPath</key><string>${xml(path.join(logDirectory,`${label}.error.log`))}</string>\n</dict></plist>\n`;
}
function launch(args,allowFailure=false){try{return execFileSync('/bin/launchctl',args,{encoding:'utf8',stdio:['ignore','pipe','pipe']});}catch(error){if(!allowFailure)throw new Error(`launchctl ${args[0]} failed: ${error.stderr?.toString().trim() || error.message}`);return null;}}
async function unload(label) {
  launch(['bootout',`${domain}/${label}`],true);
  for(let attempt=0;attempt<30;attempt++) {
    if(launch(['print',`${domain}/${label}`],true)===null) {await new Promise((resolve)=>setTimeout(resolve,500));return;}
    await new Promise((resolve)=>setTimeout(resolve,100));
  }
  throw new Error(`The previous ${label} job is still unloading. Check its logs before reinstalling.`);
}
export async function restoreSkills({home,app,data}) {
    const saved=JSON.parse(await readFile(path.join(data,'state.json'),'utf8'));
    // The pending journal covers a crash between directory swaps and the state commit.
    for(const entry of [...(saved.syncPending || [])].reverse()) {
      if(entry.replaceRoot) {
        const current=await lstat(entry.path).catch(()=>null);
        const managed=current?.isSymbolicLink() && await readlink(entry.path)===entry.source;
        if(entry.previous && existsSync(entry.previous)) {
          if(current&&!managed)throw new Error(`Refusing to replace changed skill root: ${entry.path}`);
          if(managed)await rm(entry.path);await rename(entry.previous,entry.path);
        }else if(!entry.previous&&managed)await rm(entry.path);
      }
      if(entry.exportPrevious&&existsSync(entry.exportPrevious)) {
        if(existsSync(entry.source))for(const name of await readdir(entry.source))if(!(await lstat(path.join(entry.source,name))).isSymbolicLink())throw new Error(`Refusing to delete changed export: ${entry.source}`);
        await rm(entry.source,{recursive:true,force:true});await rename(entry.exportPrevious,entry.source);
      }
      await rm(entry.stage,{recursive:true,force:true});saved.syncPending.pop();await persist();
    }
    for(const id of [...(saved.nativePending||[])].reverse()) {
      if(!/^[\da-f-]{36}$/.test(id))throw new Error('Invalid native recovery backup.');
      const backup=JSON.parse(await readFile(path.join(data,'backups',`${id}.json`),'utf8'));
      const roots=[await realpath(path.join(app,'../..')),path.join(home,'.codex'),path.join(home,'.claude'),path.join(home,'.config/opencode'),path.join(home,'.pi/agent')];
      if(typeof backup.path!=='string'||!roots.some((root)=>backup.path.startsWith(root+path.sep)))throw new Error('Native recovery target is outside managed roots.');
      if(backup.existed) {await mkdir(path.dirname(backup.path),{recursive:true});await writeFile(backup.path,backup.content,{mode:0o600});}
      else await rm(backup.path,{force:true});saved.nativePending.pop();await persist();
    }
    for(const move of [...(saved.prunePending||[])].reverse()) {
      const sourceRoot=await realpath(path.join(app,'../skills'));
      if(!move.source.startsWith(sourceRoot+path.sep)||!move.backup.startsWith(path.join(data,'disabled-skills')+path.sep))throw new Error('Invalid skill prune recovery paths.');
      if(existsSync(move.backup)) {if(existsSync(move.source))throw new Error(`Refusing to replace changed skill source: ${move.source}`);await rename(move.backup,move.source);}saved.prunePending.pop();await persist();
    }
    delete saved.nativePending;delete saved.prunePending;
    delete saved.syncPending;
    const rollback=saved.sync?.rollback||[];
    for(const entry of [...rollback].reverse()) {
      const current=await lstat(entry.path).catch(()=>null);
      const pending=saved.restorePending?.path===entry.path;
      const managed=current?.isSymbolicLink()&&(await readlink(entry.path)).startsWith(path.join(data,'skills')+path.sep);
      if(!managed&&!pending)throw new Error(`Refusing to replace changed skill root: ${entry.path}`);
      if(entry.previous&&!existsSync(entry.previous)&&!pending)throw new Error(`Original skill root is missing: ${entry.previous}`);
    }
    for(const entry of [...rollback].reverse()) {
      saved.restorePending=entry;await persist();
      const current=await lstat(entry.path).catch(()=>null);
      const managed=current?.isSymbolicLink()&&(await readlink(entry.path)).startsWith(path.join(data,'skills')+path.sep);
      if(managed)await rm(entry.path);
      if(entry.previous&&existsSync(entry.previous)) {
        if(current&&!managed)throw new Error(`Refusing to replace changed skill root: ${entry.path}`);
        await rename(entry.previous,entry.path);
      }
      rollback.pop();delete saved.restorePending;await persist();
    }
    delete saved.sync;await persist();
    async function persist() {
      const temporary=path.join(data,'state.restore.tmp');await writeFile(temporary,JSON.stringify(saved,null,2),{mode:0o600});await rename(temporary,path.join(data,'state.json'));
    }
}
export async function main(command=process.argv[2]) {
  if(process.platform!=='darwin')throw new Error('The login-service installer currently supports macOS. Run npm start on other platforms.');
  if(command==='status') {for(const label of labels) {const result=launch(['print',`${domain}/${label}`],true);console.log(`${label}: ${result?.match(/state = (\w+)/)?.[1] || 'not loaded'}`);}console.log('URL: http://agent-hub.localhost:1355');console.log(`Logs: ${logs}`);return;}
  if(command==='restart') {for(const label of labels)launch(['kickstart','-k',`${domain}/${label}`]);console.log('Agent Hub restarted.');return;}
  if(command==='uninstall') {
    for(const label of [...labels].reverse()){launch(['bootout',`${domain}/${label}`],true);await rm(path.join(directory,`${label}.plist`),{force:true});}
    console.log('Login services removed. Configuration, skills, backups, and usage cache are preserved.');return;
  }
  if(command==='restore-skills') {await restoreSkills({home,app,data});console.log('Original skill roots restored.');return;}
  if(command!=='install')throw new Error('Use: npm run service -- install|status|restart|uninstall|restore-skills');
  if(!existsSync(path.join(app,'dist/index.html')))throw new Error('Run npm run build before installing the service.');
  const portless=executable('portless');if(!portless)throw new Error('Portless is missing. Install Portless before continuing.');
  // A user-level HTTP proxy avoids privileged ports and certificate changes.
  const node=await realpath(process.execPath);const cli=await realpath(portless);
  const env={PATH:[path.dirname(node),path.join(home,'.local/bin'),'/opt/homebrew/bin','/usr/local/bin','/usr/bin','/bin','/usr/sbin','/sbin'].join(':'),PORTLESS_STATE_DIR:path.join(data,'portless'),PORTLESS_PORT:'1355',PORTLESS_HTTPS:'0',PORTLESS_SYNC_HOSTS:'0',NODE_ENV:'production'};
  await mkdir(directory,{recursive:true});await mkdir(logs,{recursive:true,mode:0o700});
  const definitions=[
    ['dev.agent-hub.proxy',[node,cli,'proxy','start','--foreground','--no-tls','--port','1355']],
    ['dev.agent-hub',[node,cli,'agent-hub',node,path.join(app,'server/index.mjs')]],
  ];
  for(const [label,args] of definitions) {
    const file=path.join(directory,`${label}.plist`);const content=plist(label,args,app,env,logs);
    if(existsSync(file) && !(await readFile(file,'utf8')).includes(`<string>${xml(label)}</string>`))throw new Error(`Existing service file does not belong to Agent Hub: ${file}`);
    await writeFile(file,content,{mode:0o600});execFileSync('/usr/bin/plutil',['-lint',file],{stdio:'pipe'});
    await unload(label);launch(['enable',`${domain}/${label}`]);launch(['bootstrap',domain,file]);
  }
  const stateFile=path.join(data,'state.json');const saved=existsSync(stateFile)?JSON.parse(await readFile(stateFile,'utf8')):{};saved.serviceUrl='http://agent-hub.localhost:1355';await writeFile(stateFile,JSON.stringify(saved,null,2),{mode:0o600});
  console.log('Agent Hub starts at login and restarts after failures.');console.log('URL: http://agent-hub.localhost:1355');console.log(`Logs: ${logs}`);
}
if(process.argv[1]===fileURLToPath(import.meta.url)) main().catch((error)=>{console.error(error.message);process.exitCode=1;});
