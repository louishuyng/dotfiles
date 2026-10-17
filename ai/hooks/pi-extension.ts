import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { aiRoot, hookContexts } from './context.mjs';

export default function (pi: ExtensionAPI) {
  pi.on('before_agent_start', async event => {
    const contexts = await hookContexts(aiRoot, 'pi');
    if (contexts.length) return { systemPrompt: event.systemPrompt + '\n\n' + contexts.join('\n\n') };
  });
}
