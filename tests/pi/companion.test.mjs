import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, realpathSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath, pathToFileURL } from 'node:url';
import test from 'node:test';

const piCli = realpathSync(execFileSync('which', ['pi'], { encoding: 'utf8' }).trim());
const require = createRequire(piCli);
const { createJiti } = require('jiti');
const jiti = createJiti(import.meta.url, {
  fsCache: false,
  alias: { '@earendil-works/pi-tui': require.resolve('@earendil-works/pi-tui') },
});
const { default: companion } = await jiti.import(fileURLToPath(new URL('../../pi/agent/extensions/companion.ts', import.meta.url)));
const { visibleWidth } = await import(require.resolve('@earendil-works/pi-tui'));
const plain = text => text.replace(/\x1b\[[0-9;]*m/g, '');

function harness(t, { mode = 'tui', idle = true, staticMotion = false, palette } = {}) {
  const events = new Map();
  const commands = new Map();
  const timers = new Map();
  const nativeTimeout = globalThis.setTimeout;
  const nativeClear = globalThis.clearTimeout;
  let now = 0;
  let component;
  let renders = 0;
  let mounts = 0;
  let nextId = 0;
  let shade = '36';
  globalThis.setTimeout = (callback, delay) => {
    const handle = { id: ++nextId, unref() {} };
    timers.set(handle, { callback, at: now + delay });
    return handle;
  };
  globalThis.clearTimeout = handle => timers.delete(handle);
  const theme = palette ?? { fg: (_role, text) => `\x1b[${shade}m${text}\x1b[0m` };
  const notifications = [];
  const ctx = {
    mode,
    isIdle: () => idle,
    ui: {
      setWidget(key, factory, options) {
        assert.equal(key, 'pip-companion');
        const previous = component;
        component = undefined;
        previous?.dispose();
        if (factory) {
          assert.equal(options.placement, 'belowEditor');
          mounts += 1;
          component = factory({ requestRender: () => renders++ }, theme);
        }
      },
      notify: (...args) => notifications.push(args),
    },
  };
  companion({
    registerFlag(name, options) {
      assert.equal(name, 'companion-static');
      assert.equal(options.default, false);
    },
    getFlag: () => staticMotion,
    on: (event, handler) => events.set(event, handler),
    registerCommand: (name, spec) => commands.set(name, spec.handler),
  });
  const emit = (name, event = {}) => events.get(name)?.(event, ctx);
  t.after(() => {
    emit('session_shutdown');
    globalThis.setTimeout = nativeTimeout;
    globalThis.clearTimeout = nativeClear;
  });
  return {
    emit,
    start: () => emit('session_start'),
    command: args => commands.get('companion')(args, ctx),
    lines: (width = 80) => component?.render(width) ?? [],
    text: (width = 80) => (component?.render(width) ?? []).map(plain).join('\n'),
    get component() { return component; },
    get timers() { return timers.size; },
    get renders() { return renders; },
    get mounts() { return mounts; },
    notifications,
    recolor: () => { shade = '35'; component?.invalidate(); },
    advance(ms) {
      const end = now + ms;
      for (;;) {
        const next = [...timers].sort((a, b) => a[1].at - b[1].at)[0];
        if (!next || next[1].at > end) break;
        now = next[1].at;
        timers.delete(next[0]);
        next[1].callback();
      }
      now = end;
    },
  };
}

test('no factory-time resources; idle blinks are sparse and tools animate at 400 ms', t => {
  const h = harness(t);
  assert.equal(h.timers, 0);
  h.start();
  assert.equal(h.timers, 1);
  assert.match(h.text(), /Ready when you are/);
  h.advance(5799);
  assert.equal(h.renders, 0);
  h.advance(1);
  assert.match(h.text(), /☾ ─ ☽/);
  h.advance(200);
  assert.match(h.text(), /☾ ○ ☽/);
  h.emit('agent_start');
  const initial = h.text();
  h.advance(399);
  assert.equal(h.text(), initial);
  h.advance(1);
  assert.notEqual(h.text(), initial);
  h.emit('tool_execution_start', { toolCallId: 'one' });
  h.emit('tool_execution_start', { toolCallId: 'two' });
  h.emit('tool_execution_end', { toolCallId: 'one' });
  assert.match(h.text(), /Using tools/);
  h.emit('tool_execution_end', { toolCallId: 'two' });
  assert.match(h.text(), /Thinking/);
  assert.equal(h.timers, 1);
});

test('nested prompts override work; only final settlement celebrates', t => {
  const h = harness(t);
  h.start();
  h.emit('agent_start');
  h.emit('ui_prompt_start');
  h.emit('ui_prompt_start');
  assert.match(h.text(), /Waiting for you/);
  assert.equal(h.timers, 0);
  h.emit('ui_prompt_end');
  assert.match(h.text(), /Waiting for you/);
  h.emit('ui_prompt_end');
  h.emit('ui_prompt_end');
  assert.match(h.text(), /Thinking/);
  h.emit('agent_end');
  assert.match(h.text(), /Thinking/);
  h.emit('agent_start');
  assert.equal(h.timers, 1);
  h.emit('agent_settled', { aborted: false });
  assert.match(h.text(), /Finished/);
  h.advance(2000);
  assert.match(h.text(), /Ready when you are/);
});

test('aborted and final assistant errors never celebrate; later success can recover', t => {
  const h = harness(t);
  h.start();
  h.emit('agent_start');
  h.emit('agent_settled', { aborted: true });
  assert.match(h.text(), /Stopped/);
  assert.equal(h.timers, 0);
  h.emit('agent_start');
  h.emit('message_end', { message: { role: 'assistant', stopReason: 'error' } });
  h.emit('message_end', { message: { role: 'toolResult' } });
  h.emit('agent_settled', { aborted: false });
  assert.match(h.text(), /Needs attention/);
  assert.equal(h.timers, 0);
  h.emit('agent_start');
  h.emit('message_end', { message: { role: 'assistant', stopReason: 'error' } });
  h.emit('message_end', { message: { role: 'assistant', stopReason: 'stop' } });
  h.emit('agent_settled', { aborted: false });
  assert.match(h.text(), /Finished/);
});

test('pause/hide stop all timers; resume/show do not duplicate widgets or timers', async t => {
  const h = harness(t);
  h.start();
  await h.command('pause');
  assert.equal(h.timers, 0);
  h.emit('agent_start');
  assert.match(h.text(), /Thinking/);
  assert.equal(h.timers, 0);
  assert.match(h.text(), /motion paused/);
  await h.command('resume');
  await h.command('resume');
  assert.equal(h.timers, 1);
  await h.command('hide');
  assert.equal(h.component, undefined);
  assert.equal(h.timers, 0);
  h.emit('agent_settled', { aborted: false });
  assert.equal(h.timers, 0);
  await h.command('show');
  const mounts = h.mounts;
  await h.command('show');
  assert.equal(h.mounts, mounts);
  assert.equal(h.timers, 1);
  await h.command('unknown');
  assert.equal(h.notifications.length, 1);
});

test('static flag, disposal, shutdown and replacement release all resources', async t => {
  const h = harness(t, { staticMotion: true, idle: false });
  h.start();
  assert.match(h.text(), /Thinking/);
  assert.equal(h.timers, 0);
  await h.command('resume');
  const previous = h.component;
  h.start();
  assert.equal(h.timers, 0);
  await h.command('resume');
  previous.dispose();
  assert.equal(h.timers, 1);
  h.component.dispose();
  assert.equal(h.timers, 0);
  h.emit('session_shutdown');
  h.emit('session_shutdown');
  const renders = h.renders;
  h.advance(30000);
  h.emit('agent_start');
  assert.equal(h.renders, renders);
  assert.equal(h.timers, 0);
});

for (const mode of ['rpc', 'json', 'print']) {
  test(`${mode} mode has no widget, timers, or companion notifications`, async t => {
    const h = harness(t, { mode });
    h.start();
    h.emit('agent_start');
    h.emit('tool_execution_start', { toolCallId: 'one' });
    h.emit('ui_prompt_start');
    h.emit('agent_settled', { aborted: false });
    await h.command('show');
    assert.equal(h.mounts, 0);
    assert.equal(h.timers, 0);
    assert.deepEqual(h.notifications, []);
  });
}

test('the theater theme validates, renders the panel, and keeps text contrast on its panels', async t => {
  let packageRoot = dirname(piCli);
  while (!existsSync(join(packageRoot, 'package.json'))) {
    assert.notEqual(packageRoot, dirname(packageRoot), 'Pi package root not found');
    packageRoot = dirname(packageRoot);
  }
  const themeModule = pathToFileURL(join(packageRoot, 'dist/modes/interactive/theme/theme.js'));
  const schemaModule = pathToFileURL(join(packageRoot, 'dist/modes/interactive/theme/theme-schema.js'));
  const { loadThemeFromPath, setThemeJsonValidator } = await import(themeModule.href);
  const { validateThemeJson } = await import(schemaModule.href);
  setThemeJsonValidator(validateThemeJson);
  const path = new URL('../../pi/agent/themes/wired-theater.json', import.meta.url);
  const document = JSON.parse(readFileSync(path, 'utf8'));
  const palette = loadThemeFromPath(fileURLToPath(path), 'truecolor');
  assert.equal(palette.name, 'wired-theater');
  assert.equal(palette.appearance, 'dark');
  const h = harness(t, { palette, staticMotion: true });
  h.start();
  assert.match(h.text(), /PIP.*WIRED COMPANION/);
  assert.match(h.text(), /☾ ○ ☽/);
  assert.ok(h.lines().every(line => visibleWidth(line) === 78));

  const resolve = value => document.vars[value] ?? value;
  const luminance = hex => {
    const channels = hex.slice(1).match(/../g).map(channel => {
      const value = parseInt(channel, 16) / 255;
      return value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4;
    });
    return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722;
  };
  const roles = ['text', 'muted', 'dim', 'accent', 'success', 'warning', 'error', 'mdHeading', 'syntaxComment'];
  const backgrounds = ['void', 'stage', 'curtain', resolve(document.colors.toolSuccessBg), resolve(document.colors.toolErrorBg)];
  for (const role of roles) {
    for (const background of backgrounds) {
      const foregroundLuminance = luminance(resolve(document.colors[role]));
      const backgroundLuminance = luminance(resolve(background));
      const ratio = (Math.max(foregroundLuminance, backgroundLuminance) + 0.05)
        / (Math.min(foregroundLuminance, backgroundLuminance) + 0.05);
      assert.ok(ratio >= 4.5, `${role} on ${background}: ${ratio.toFixed(2)}:1`);
    }
  }
});

test('all moods fit narrow/wide terminals, retain height, and use fresh theme styling', t => {
  const h = harness(t);
  h.start();
  const transitions = [
    ['session_start', {}],
    ['agent_start', {}],
    ['tool_execution_start', { toolCallId: 'one' }],
    ['ui_prompt_start', {}],
    ['ui_prompt_end', {}],
    ['agent_settled', { aborted: false }],
    ['agent_settled', { aborted: true }],
    ['agent_start', {}],
    ['message_end', { message: { role: 'assistant', stopReason: 'error' } }],
    ['agent_settled', { aborted: false }],
  ];
  for (const [event, payload] of transitions) {
    h.emit(event, payload);
    for (const width of [0, 1, 20, 39, 40, 60, 80, 120]) {
      const lines = h.lines(width);
      assert.equal(lines.length, width === 0 ? 0 : width < 40 ? 1 : 5);
      if (width >= 40) {
        assert.match(plain(lines[0]), /PIP.*WIRED COMPANION/);
        assert.ok(lines.every(line => visibleWidth(line) === width - 2));
        assert.ok(lines.slice(1, -1).every(line => plain(line).startsWith('  │') && plain(line).endsWith('│')));
      }
      assert.ok(lines.every(line => visibleWidth(line) <= width));
    }
  }
  const before = h.lines();
  h.recolor();
  assert.notDeepEqual(h.lines(), before);
  assert.equal(h.text(), before.map(plain).join('\n'));
});
