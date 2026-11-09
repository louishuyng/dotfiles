#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { readFileSync, existsSync } from 'node:fs';

const dispatch = join(homedir(), '.dotfiles/ai/hooks/factory-bridge/dispatch.mjs');
const sample = {
  session_id: 'synthetic-verify-session',
  hook_event_name: 'Stop',
  cwd: '/Users/louishuyng/LX14/repository/github.com/regask/.worktrees/platform-services-REG-16989',
  last_assistant_message: 'FACTORY_STEP_DONE: REG-16989:3b review ready',
  stop_hook_active: false,
  background_tasks: [],
  // prompt_id intentionally omitted — Claude may not send it; bridge must not invent
};
const r = spawnSync(process.execPath, [dispatch], {
  input: JSON.stringify(sample),
  encoding: 'utf8',
  timeout: 5000,
});
console.log('exit', r.status);
const log = join(homedir(), '.config/rex-factory-completion-bridge/logs/dispatch.log');
if (existsSync(log)) {
  const lines = readFileSync(log, 'utf8').trim().split('\n');
  console.log('last_log', lines[lines.length - 1] || '(empty)');
}
process.exit(r.status === 0 ? 0 : 1);
