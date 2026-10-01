import fs from 'node:fs';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const run = promisify(execFile);

export default {
  id: 'rtk',
  async setup(ctx) {
    const { executable, instructionsPath } = ctx.options;
    let instructions = fs.readFileSync(instructionsPath, 'utf8');

    await ctx.session.hook('context', ({ system }) => {
      try {
        instructions = fs.readFileSync(instructionsPath, 'utf8');
      } catch {
        // Preserve the last known rules during a temporary read failure.
      }
      system.push({ type: 'text', text: instructions });
    });

    await ctx.shell.hook('create.before', async (event) => {
      try {
        const { stdout } = await run(executable, ['rewrite', event.command], {
          cwd: event.cwd,
          encoding: 'utf8',
          timeout: 5000,
        });
        const rewritten = stdout.trim();
        if (rewritten) event.command = rewritten;
      } catch {
        // Unsupported commands and rewrite failures retain the original command.
      }
    });
  },
};
