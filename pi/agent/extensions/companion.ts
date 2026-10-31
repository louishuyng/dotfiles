import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';
import { truncateToWidth, visibleWidth } from '@earendil-works/pi-tui';

type Mood = 'ready' | 'working' | 'tools' | 'waiting' | 'finished' | 'stopped' | 'error';

const labels: Record<Mood, string> = {
  ready: 'Ready when you are',
  working: 'Thinking',
  tools: 'Using tools',
  waiting: 'Waiting for you',
  finished: 'Finished',
  stopped: 'Stopped',
  error: 'Needs attention',
};

export default function companion(pi: ExtensionAPI) {
  pi.registerFlag('companion-static', {
    description: 'Show Pip without animation',
    type: 'boolean',
    default: false,
  });

  let context: ExtensionContext | undefined;
  let timer: ReturnType<typeof setTimeout> | undefined;
  let requestRender: (() => void) | undefined;
  let activeComponent: object | undefined;
  let hidden = false;
  let paused = false;
  let busy = false;
  let prompts = 0;
  let failed = false;
  let outcome: Mood = 'ready';
  let frame = 0;
  let blinking = false;
  const tools = new Set<string>();

  function mood(): Mood {
    if (prompts > 0) return 'waiting';
    if (busy) return tools.size > 0 ? 'tools' : 'working';
    return outcome;
  }

  function stopTimer() {
    if (timer !== undefined) clearTimeout(timer);
    timer = undefined;
  }

  function schedule() {
    stopTimer();
    if (!context || hidden || paused || !requestRender) return;
    const state = mood();
    const delay = state === 'ready' ? (blinking ? 200 : 5800)
      : state === 'working' || state === 'tools' ? 400
      : state === 'finished' ? 2000 : undefined;
    if (delay === undefined) return;
    timer = setTimeout(() => {
      timer = undefined;
      if (state === 'ready') blinking = !blinking;
      else if (state === 'finished') outcome = 'ready';
      else frame = (frame + 1) % 4;
      requestRender?.();
      schedule();
    }, delay);
    timer.unref?.();
  }

  function update() {
    if (!context) return;
    frame = 0;
    blinking = false;
    requestRender?.();
    schedule();
  }

  function mount() {
    if (!context || hidden) return;
    context.ui.setWidget('pip-companion', (tui, theme) => {
      const component = {
        render(width: number): string[] {
          if (width <= 0) return [];
          const state = mood();
          const color = state === 'error' ? 'error'
            : state === 'waiting' || state === 'stopped' ? 'warning'
            : state === 'finished' ? 'success' : 'accent';
          const moving = state === 'working' || state === 'tools';
          const face = state === 'working' ? ['◐ · ◑', '◑ ◉ ◐', '◐ ◉ ◑', '◑ · ◐'][frame]
            : state === 'tools' ? ['◇ · ◇', '◇ ◈ ◇', '◈ ◇ ◈', '◇ ◈ ◇'][frame]
            : state === 'waiting' ? '☾ ? ☽'
            : state === 'finished' ? '✦ ◉ ✦'
            : state === 'error' ? '◇ ! ◇'
            : blinking ? '☾ ─ ☽' : '☾ ○ ☽';
          const label = labels[state];
          if (width < 40) {
            return [truncateToWidth(` ${theme.fg(color, face)} ${theme.fg('text', `Pip / ${label}`)}`, width)];
          }

          const innerWidth = width - 6;
          const border = (text: string) => theme.fg('border', text);
          const row = (content: string) => {
            const fitted = truncateToWidth(content, innerWidth);
            return `  ${border('│')}${fitted}${' '.repeat(innerWidth - visibleWidth(fitted))}${border('│')}`;
          };
          const rule = (left: string, title: string, right: string) => {
            const fitted = truncateToWidth(title, innerWidth);
            return `  ${border(left)}${fitted}${border('─'.repeat(innerWidth - visibleWidth(fitted)) + right)}`;
          };
          const particles = (lane: number) => {
            const cells = Array<string>(innerWidth).fill(' ');
            const drift = moving ? [-1, 0, 1, 0][frame] : 0;
            for (let i = 0; i < 3; i++) {
              const position = Math.floor(innerWidth * (i + 1) / 4) + drift + lane * 2;
              cells[position] = (i + lane + frame) % 3 === 0 ? '✧' : '·';
            }
            return theme.fg(lane === 0 ? 'accent' : 'mdHeading', cells.join(''));
          };
          return [
            rule('┌', ` ${theme.fg('accent', 'PIP')} ${theme.fg('mdHeading', '/ WIRED COMPANION')} `, '┐'),
            row(` ${theme.fg(color, `› ${face}`)}   ${theme.fg('text', label)}  ${theme.fg('mdHeading', moving ? ['◐', '◑', '●', '○'][frame] : '○')}`),
            row(particles(0)),
            row(particles(1)),
            rule('└', ` ${theme.fg('text', paused ? 'motion paused' : '/companion pause')} `, '┘'),
          ];
        },
        invalidate() {},
        dispose() {
          // A replaced widget must not clear the newer widget's timer or render callback.
          if (activeComponent !== component) return;
          stopTimer();
          requestRender = undefined;
          activeComponent = undefined;
        },
      };
      activeComponent = component;
      requestRender = () => tui.requestRender();
      schedule();
      return component;
    }, { placement: 'belowEditor' });
  }

  pi.on('session_start', (_event, ctx) => {
    if (ctx.mode !== 'tui') return;
    stopTimer();
    context = ctx;
    hidden = false;
    paused = pi.getFlag('companion-static') === true;
    busy = !ctx.isIdle();
    prompts = 0;
    failed = false;
    outcome = 'ready';
    tools.clear();
    frame = 0;
    blinking = false;
    mount();
  });

  pi.on('agent_start', () => {
    if (!context) return;
    busy = true;
    failed = false;
    outcome = 'ready';
    tools.clear();
    update();
  });

  pi.on('message_end', (event) => {
    if (!context || event.message.role !== 'assistant') return;
    failed = event.message.stopReason === 'error';
  });

  pi.on('tool_execution_start', (event) => {
    if (!context) return;
    tools.add(event.toolCallId);
    update();
  });

  pi.on('tool_execution_end', (event) => {
    if (!context) return;
    tools.delete(event.toolCallId);
    update();
  });

  pi.on('ui_prompt_start', () => {
    if (!context) return;
    prompts += 1;
    update();
  });

  pi.on('ui_prompt_end', () => {
    if (!context) return;
    prompts = Math.max(0, prompts - 1);
    update();
  });

  pi.on('agent_settled', (event) => {
    if (!context) return;
    busy = false;
    tools.clear();
    outcome = event.aborted ? 'stopped' : failed ? 'error' : 'finished';
    update();
  });

  pi.registerCommand('companion', {
    description: 'Control Pip: pause, resume, hide, show',
    handler: async (args, ctx) => {
      if (ctx.mode !== 'tui' || !context) return;
      switch (args.trim()) {
        case 'pause': paused = true; break;
        case 'resume': paused = false; break;
        case 'hide':
          hidden = true;
          stopTimer();
          context.ui.setWidget('pip-companion', undefined);
          return;
        case 'show':
          if (hidden) {
            hidden = false;
            mount();
          }
          return;
        default:
          ctx.ui.notify('Pip: /companion pause | resume | hide | show', 'info');
          return;
      }
      update();
    },
  });

  pi.on('session_shutdown', () => {
    stopTimer();
    const previous = context;
    context = undefined;
    previous?.ui.setWidget('pip-companion', undefined);
    requestRender = undefined;
    activeComponent = undefined;
    tools.clear();
  });
}
