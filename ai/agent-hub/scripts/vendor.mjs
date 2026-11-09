import { homedir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Vendors } from '../server/vendor.mjs';

const [command, name, ref] = process.argv.slice(2);
if (command !== 'update' || !name) {
  console.error('Usage: node scripts/vendor.mjs update <name> [ref]');
  process.exit(2);
}
const root = fileURLToPath(new URL('../../..', import.meta.url));
const vendors = new Vendors({ root, home: homedir(), data: path.join(homedir(), '.local/share/agent-hub') });
const plan = await vendors.preview({ name, ref });
console.log(`${name}: ${plan.from.version} (${plan.from.commit.slice(0, 7)}) -> ${plan.version} (${plan.commit.slice(0, 7)}), ${plan.changes.length} file(s) changed`);
for (const change of plan.changes) console.log(`  ${change.status.padEnd(7)} ${change.path}`);
await vendors.apply({ name, id: plan.id });
console.log('Review the vendor diff before committing: vendored prompts run in every agent.');
console.log('Native plugins were not touched; they install upstream latest, so sync them from Agent Hub after review.');
