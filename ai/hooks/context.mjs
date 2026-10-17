import { readFile, realpath } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const CONTEXT_FILES = {
  adhd: 'skills/i-have-adhd/SKILL.md',
  ponytail: 'skills/ponytail/SKILL.md',
  crit: 'hooks/crit.md',
};
export const aiRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export const enabledFor = (hook, tool) => hook.enabled && !(hook.disabledAgents || []).includes(tool);
export const isContextHook = hook => hook.context !== undefined || hook.text !== undefined || hook.skill !== undefined;

export async function readContext(root, hook) {
  let file; let source;
  if (hook.text !== undefined) {
    if (typeof hook.text !== 'string' || !hook.text.trim()) throw new Error('Context text must not be empty.');
    file = path.join(root, 'config/shared-setup.json'); source = hook.text;
  } else {
    if (hook.skill !== undefined) {
      if (typeof hook.skill !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(hook.skill)) throw new Error('Choose a shared skill name.');
      file = path.join(root, 'skills', hook.skill, 'SKILL.md');
      const skills = await realpath(path.join(root, 'skills'));
      if (!(await realpath(file)).startsWith(skills + path.sep)) throw new Error('Skill context must resolve inside ai/skills.');
    } else {
      if (!Object.hasOwn(CONTEXT_FILES, hook.context)) throw new Error('Unknown shared hook context.');
      file = path.join(root, CONTEXT_FILES[hook.context]);
    }
    source = await readFile(file, 'utf8');
  }
  if (Buffer.byteLength(source) > 2 * 1024 * 1024) throw new Error('Hook context exceeds 2 MB.');
  const body = hook.text !== undefined ? source : source.replace(/^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/, '').trim();
  return { path: file, content: `Shared ${hook.id} hook is active. Apply these instructions for this session:\n\n${body}` };
}

export async function hookContexts(root, tool, id) {
  const setup = JSON.parse(await readFile(path.join(root, 'config/shared-setup.json'), 'utf8'));
  const contexts = [];
  for (const hook of setup.hooks) {
    if (!isContextHook(hook) || id && hook.id !== id || !enabledFor(hook, tool)) continue;
    contexts.push((await readContext(root, hook)).content);
  }
  return contexts;
}

export async function hookOutput(root, tool, id, event) {
  const contexts = await hookContexts(root, tool, id);
  if (!contexts.length) return {};
  const content = contexts.join('\n\n');
  return tool === 'cursor' ? { additional_context: content }
    : { hookSpecificOutput: { hookEventName: event, additionalContext: content } };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [tool, id, event] = process.argv.slice(2);
  if (!['codex', 'claude', 'gemini', 'cursor'].includes(tool) || !id || !event) {
    process.stderr.write('Use context.mjs <agent> <hook-id> <event>.\n'); process.exitCode = 1;
  } else {
    hookOutput(aiRoot, tool, id, event).then(output => process.stdout.write(JSON.stringify(output) + '\n'))
      .catch(() => { process.stderr.write('Shared hook configuration could not be loaded. Check dotfiles/ai.\n'); process.exitCode = 1; });
  }
}
