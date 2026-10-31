import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, realpathSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import test from 'node:test';

const pi_cli = realpathSync(execFileSync('which', ['pi'], { encoding: 'utf8' }).trim());
const require = createRequire(pi_cli);
let package_root = dirname(pi_cli);
while (!existsSync(join(package_root, 'package.json'))) {
  assert.notEqual(package_root, dirname(package_root), 'Pi package root not found');
  package_root = dirname(package_root);
}
const { createJiti } = require('jiti');
const jiti = createJiti(import.meta.url, {
  fsCache: false,
  alias: {
    '@earendil-works/pi-tui': require.resolve('@earendil-works/pi-tui'),
    '@earendil-works/pi-coding-agent': join(package_root, 'dist/index.js'),
  },
});
const { default: header } = await jiti.import(fileURLToPath(new URL('../../pi/agent/extensions/droid_header.ts', import.meta.url)));
const { visibleWidth } = await import(require.resolve('@earendil-works/pi-tui'));
const { loadThemeFromPath, setThemeInstance } = await import(pathToFileURL(join(package_root, 'dist/modes/interactive/theme/theme.js')).href);
const theme_path = new URL('../../pi/agent/themes/wired-theater.json', import.meta.url);
const plain = line => line.replace(/\x1b\[[0-9;]*m/g, '');

function harness(mode = 'tui', color_mode = 'truecolor') {
  const events = new Map();
  let component;
  let mounts = 0;
  const ctx = {
    mode,
    ui: {
      theme: loadThemeFromPath(fileURLToPath(theme_path), color_mode),
      setHeader(factory) {
        mounts++;
        component = factory?.();
      },
    },
  };
  setThemeInstance(ctx.ui.theme);
  header({ on: (event, handler) => events.set(event, handler) });
  return {
    ctx,
    emit: event => events.get(event)?.({}, ctx),
    get component() { return component; },
    get mounts() { return mounts; },
  };
}

test('original logo and hints fit all widths and both terminal color modes', () => {
  for (const mode of ['truecolor', '256color']) {
    const h = harness('tui', mode);
    assert.equal(h.mounts, 0);
    h.emit('session_start');
    for (const width of [0, 1, 3, 12, 19, 20, 30, 40, 80, 120]) {
      const lines = h.component.render(width);
      assert.ok(lines.every(line => visibleWidth(line) <= width), `${mode}: width ${width}`);
      if (width === 0) assert.deepEqual(lines, []);
      if (width >= 40) {
        assert.equal(lines.length, 9);
        assert.match(lines.map(plain).join('\n'), /████████████╗/);
        assert.match(lines.map(plain).join('\n'), /Pi v1\./);
        assert.match(lines.map(plain).join('\n'), /●.*ready/);
      }
    }
    const wide = h.component.render(120).join('\n');
    assert.match(wide, mode === 'truecolor' ? /38;2;/ : /38;5;/);
    h.emit('session_shutdown');
    assert.equal(h.component, undefined);
    h.emit('session_start');
    assert.equal(h.component.render(120).length, 9);
  }
});

test('gradient follows theme changes and header input stays with Pi', () => {
  const h = harness();
  h.emit('session_start');
  const before = h.component.render(120);
  assert.equal(h.component.handleInput, undefined);
  h.ctx.ui.theme = loadThemeFromPath(fileURLToPath(theme_path), '256color');
  const after = h.component.render(120);
  assert.notDeepEqual(after, before);
  assert.deepEqual(after.map(plain), before.map(plain));
  h.component.invalidate();
  assert.deepEqual(h.component.render(120), after);
});

for (const mode of ['rpc', 'json', 'print']) {
  test(`${mode} mode never mounts a header`, () => {
    const h = harness(mode);
    h.emit('session_start');
    h.emit('session_shutdown');
    assert.equal(h.mounts, 0);
  });
}

test('screenshot layout and companion exclusion are configured', () => {
  const settings = JSON.parse(readFileSync(new URL('../../pi/agent/settings.json', import.meta.url), 'utf8'));
  const styling = JSON.parse(readFileSync(new URL('../../pi/agent/pi-droid-styling.json', import.meta.url), 'utf8'));
  assert.equal(settings.theme, 'qoder-cli');
  assert.equal(settings.quietStartup, false);
  assert.ok(settings.extensions.includes('!extensions/companion.ts'));
  assert.equal(styling.presentationStyle, 'reasonix');
  assert.equal(styling.userZoneStyle, 'gemini');
  assert.equal(styling.inputBox.style, 'halfblock');
});
