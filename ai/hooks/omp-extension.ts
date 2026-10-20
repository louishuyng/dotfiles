import type { ExtensionAPI } from '@oh-my-pi/pi-coding-agent';
import { matchesKey } from '@oh-my-pi/pi-tui';
import { aiRoot, hookContexts } from './context.mjs';

export default function (omp: ExtensionAPI) {
  omp.on('before_agent_start', async event => {
    const contexts = await hookContexts(aiRoot, 'omp');
    if (contexts.length) return { systemPrompt: event.systemPrompt + '\n\n' + contexts.join('\n\n') };
  });

  let removeZedShortcut: (() => void) | undefined;
  omp.on('session_start', (_event, ctx) => {
    removeZedShortcut?.();
    if (!ctx.hasUI) return;
    // The native keymap frees Ctrl+G; registerShortcut still reserves that chord.
    removeZedShortcut = ctx.ui.onTerminalInput(data => {
      if (!matchesKey(data, 'ctrl+g')) return;
      const cwd = ctx.sessionManager.getCwd();
      void (async () => {
        const repository = await omp.exec('git', ['rev-parse', '--show-toplevel'], { cwd });
        const project = repository.code === 0 ? repository.stdout.trim() : cwd;
        const result = await omp.exec('zed', [project], { cwd });
        if (result.code !== 0) throw new Error(result.stderr.trim() || `Zed exited with code ${result.code}`);
      })().catch(error => ctx.ui.notify(error instanceof Error ? error.message : String(error), 'error'));
      return { consume: true };
    });
  });
}
