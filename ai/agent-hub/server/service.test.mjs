import test from 'node:test';
import assert from 'node:assert/strict';
import {nativeProxyOwned,plist} from '../scripts/service.mjs';

test('clean URL migration only takes over its own system Portless service',()=>{
  const directory='/Users/example/Agent Hub & data/portless';
  const content=plist('sh.portless.proxy',['node','portless'], '/tmp',{PORTLESS_STATE_DIR:directory},'/tmp');
  assert.equal(nativeProxyOwned(content,directory),true);
  assert.equal(nativeProxyOwned(content,directory+'/other'),false);
  assert.equal(nativeProxyOwned(content.replace('PORTLESS_STATE_DIR','OTHER_STATE_DIR'),directory),false);
  assert.equal(nativeProxyOwned('',directory),false);
});
