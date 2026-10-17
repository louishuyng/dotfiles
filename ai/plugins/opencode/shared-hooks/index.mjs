import { aiRoot, hookContexts } from '../../../hooks/context.mjs';

export default {
  id: 'agent-hub-shared-hooks',
  async setup(ctx) {
    await ctx.session.hook('context', async ({ system }) => {
      for (const text of await hookContexts(aiRoot, 'opencode')) system.push({ type: 'text', text });
    });
  },
};
