import type { ExtensionAPI } from '@oh-my-pi/pi-coding-agent';
import { aiRoot, hookContexts } from './context.mjs';

export default function (omp: ExtensionAPI) {
  omp.on('before_agent_start', async event => {
    const contexts = await hookContexts(aiRoot, 'omp');
    if (contexts.length) return { systemPrompt: event.systemPrompt + '\n\n' + contexts.join('\n\n') };
  });
}
