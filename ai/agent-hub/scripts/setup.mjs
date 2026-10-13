import { mkdir, rename } from 'node:fs/promises';
import { homedir } from 'node:os';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Configuration, executable } from '../server/config.mjs';
import { CodexClient } from '../server/codex.mjs';

export async function setup(config, { strictPlugins=false }={}) {
  await config.init();
  if((await config.readState()).prunePending)throw new Error('Interrupted skill cleanup needs recovery. Run npm run service -- restore-skills first.');
  const library=await config.library();
  const inactive=library.skills.filter((s)=>!s.enabled);
  if(strictPlugins)await config.saveState({...await config.readState(),strictPluginConsent:true});
  await config.configureGlobals();
  const plan=await config.syncPreview();
  await config.syncApply({revision:plan.revision});
  let recovery;
  if(inactive.length) {
    recovery=path.join(config.data,'disabled-skills',new Date().toISOString().replace(/[:.]/g,'-'));
    await mkdir(recovery,{recursive:true,mode:0o700});
    const moves=inactive.map((skill)=>({source:path.dirname(skill.path),backup:path.join(recovery,skill.name)}));
    await config.saveState({...await config.readState(),prunePending:moves});
    const completed=[];
    try {
      for(const move of moves){await rename(move.source,move.backup);completed.push(move);}
      const saved=await config.readState();delete saved.prunePending;saved.disabledSkillRecovery=recovery;await config.saveState(saved);
    }catch(error) {
      for(const move of completed.reverse())await rename(move.backup,move.source);
      const saved=await config.readState();delete saved.prunePending;await config.saveState(saved);throw error;
    }
  }
  const state=await config.inventory();
  return {library:state.library,count:state.skills.filter((s)=>s.enabled).length,recovery,checks:state.sync.checks,warnings:plan.warnings};
}

if(process.argv[1]===fileURLToPath(import.meta.url)) {
  const home=homedir();const root=fileURLToPath(new URL('../../..',import.meta.url));
  const codex=new CodexClient({home,cwd:home,executable:executable('codex')||'codex'});
  const config=new Configuration({home,root,data:path.join(home,'.local/share/agent-hub'),codex});
  setup(config,{strictPlugins:process.argv.includes('--strict-plugins')}).then((result)=>console.log(JSON.stringify(result,null,2)))
    .catch((error)=>{console.error(error.message);process.exitCode=1;}).finally(()=>codex.close());
}
