import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

export default {
  id: 'codex-modes',
  async setup(ctx) {
    const { ponytailRoot, adhdRoot } = ctx.options;
    const { getPonytailInstructions } = require(path.join(ponytailRoot, 'hooks/ponytail-instructions.js'));
    const { getDefaultMode, normalizePersistedMode, isDeactivationCommand } = require(
      path.join(ponytailRoot, 'hooks/ponytail-config.js'),
    );
    const adhdRules = fs.readFileSync(path.join(adhdRoot, 'skills/i-have-adhd/SKILL.md'), 'utf8')
      .replace(/^---[^\S\r\n]*\r?\n[\s\S]*?\r?\n---[^\S\r\n]*(?:\r?\n|$)/, '').trim();
    const configDir = path.join(process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config'), 'opencode');
    const alwaysAdhd = fs.existsSync(path.join(configDir, '.i-have-adhd-always')) || fs.existsSync(
      path.join(process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude'), '.i-have-adhd-always'),
    );
    const state = async (sessionID) => (await ctx.storage.get(`session/${sessionID}`)) ?? {
      ponytail: getDefaultMode(), adhd: alwaysAdhd,
    };

    await ctx.command.transform((editor) => {
      editor.add({
        name: 'ponytail',
        description: 'Switch ponytail intensity (lite/full/ultra/off)',
        async execute({ sessionID, prompt, delivery }) {
          const args = prompt.text.trim();
          const current = await state(sessionID);
          const mode = args ? normalizePersistedMode(args) : current.ponytail;
          if (!mode) throw new Error('Use /ponytail lite, full, ultra, review, or off.');
          await ctx.storage.set(`session/${sessionID}`, { ...current, ponytail: mode });
          await ctx.session.prompt({ ...prompt, sessionID, delivery,
            text: `Ponytail mode is ${mode}. Confirm briefly and apply this mode for this session.` });
        },
      });
      editor.add({
        name: 'i-have-adhd',
        description: 'Enable ADHD output rules for this session',
        async execute({ sessionID, prompt, delivery }) {
          await ctx.storage.set(`session/${sessionID}`, { ...await state(sessionID), adhd: true });
          await ctx.session.prompt({ ...prompt, sessionID, delivery,
            text: 'ADHD mode is active. Apply the output rules for this session and confirm briefly.' });
        },
      });
    });

    await ctx.session.hook('prompt', async ({ sessionID, prompt }) => {
      const text = prompt.text.trim().toLowerCase().replace(/[.!?\s]+$/, '');
      if (!isDeactivationCommand(text) && text !== 'stop adhd mode') return;
      const current = await state(sessionID);
      if (isDeactivationCommand(text)) current.ponytail = 'off';
      if (text === 'stop adhd mode' || text === 'normal mode') current.adhd = false;
      await ctx.storage.set(`session/${sessionID}`, current);
    });

    await ctx.session.hook('context', async ({ sessionID, system }) => {
      const current = await state(sessionID);
      if (current.ponytail !== 'off') {
        system.push({ type: 'text', text: getPonytailInstructions(current.ponytail) });
      }
      if (current.adhd) system.push({ type: 'text', text: adhdRules });
    });
  },
};
