// tmux-style prefix for the Herdr app: keys.json binds ctrl-a to `mod.open:prefix`,
// this popup takes the next key, runs its command and closes. Keys mirror
// terminals/herdr/config.toml (the herdr CLI), which mirrors .tmux.conf.

import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { run, hc, exec, home, props, closeOverlay, theme, focused, spaces, notify } from "herdr";

const go = (name, args = {}) => () => run(name, args);

// The CLI's popups: the app has no popup terminal (terminal.peek only takes terminals it
// already shows), so run the tool in a split and zoom it. Its pane closes when it exits.
const popup = (command) => () => {
  run("pane.split", { direction: "right", argv: ["fish", "-c", command] });
  run("pane.zoom");
};

// Scripts, not async mod code: this popup closes right after the key, which drops any
// work still awaiting in it; a started exec keeps running.
const script = (name, ...args) => () => exec(`${home()}/.dotfiles/terminals/herdr-app/scripts/${name}`, args);
const smallSplit = (direction) => script("pane-split.sh", direction)();

function scrollback() {
  const t = focused()?.terminal;
  if (t) popup(`hc read ${t} | nvim -R -c 'normal G' -`)();
}

function moveTab(step) {
  const f = focused();
  const space = spaces().find((s) => s.id === f?.space);
  const i = space?.tabs.findIndex((t) => t.id === f.tab) ?? -1;
  if (i < 0) return;
  const to = i + 1 + step;
  if (to >= 1 && to <= space.tabs.length) run("tab.move", { id: f.tab, index: to });
}

function moveSpace(step) {
  const all = spaces();
  const i = all.findIndex((s) => s.id === focused()?.space);
  if (i < 0) return;
  const to = i + 1 + step;
  if (to >= 1 && to <= all.length) run("space.move", { id: all[i].id, index: to });
}

// Keyed by the typed character when no ctrl/cmd/alt is held, else by GPUI's keystroke.
const KEYS = {
  h: go("pane.go", { direction: "left" }),
  j: go("pane.go", { direction: "down" }),
  k: go("pane.go", { direction: "up" }),
  l: go("pane.go", { direction: "right" }),
  left: go("pane.swap", { direction: "left" }),
  down: go("pane.swap", { direction: "down" }),
  up: go("pane.swap", { direction: "up" }),
  right: go("pane.swap", { direction: "right" }),
  "-": () => smallSplit("down"),
  "\\": () => smallSplit("right"),
  "|": () => smallSplit("right"),
  x: go("pane.close"),
  z: go("pane.zoom"),
  c: go("tab.new"),
  X: go("tab.close"),
  ",": go("tab.rename"),
  "<": () => moveTab(-1),
  ">": () => moveTab(1),
  J: () => moveSpace(1),
  K: () => moveSpace(-1),
  "ctrl-h": go("tab.prev"),
  "ctrl-l": go("tab.next"),
  "ctrl-c": go("space.new"),
  "ctrl-j": go("space.next"),
  "ctrl-k": go("space.prev"),
  $: go("space.rename"),
  b: go("layout.toggle", { id: "sidebar" }),
  s: go("mod.open", { name: "sessions" }),
  w: go("mod.open", { name: "sessions" }),
  "?": go("app.help"),
  S: go("app.settings"),
  "/": popup("yazi"),
  i: popup("lazydocker"),
  t: popup("tuxedo"),
  R: popup("serpl"),
  "ctrl-r": popup("tuicr"),
  g: popup("gh dash"),
  n: popup("~/.dotfiles/terminals/notes/note.sh"),
  // Scrollback in nvim (the CLI's edit_scrollback); `[` too, as the copy-mode key.
  v: () => scrollback(),
  "[": () => scrollback(),
  T: () => exec(`${home()}/.dotfiles/terminals/herdr/scripts/toggle-appearance.sh`),
  // ctrl-a twice: hand ctrl-a to the program (beginning of line), like tmux send-prefix.
  "ctrl-a": () => {
    const t = focused()?.terminal;
    if (t) hc(["keys", t, "ctrl+a"]);
  },
};
for (let n = 1; n <= 9; n++) KEYS[String(n)] = go("tab.select", { index: n });
// prefix+shift+1..9 picks a space; `$` stays space.rename as in the CLI config.
[..."!@#$%^&*("].forEach((ch, i) => {
  if (ch !== "$") KEYS[ch] = go("space.select", { index: i + 1 });
});

// H/L move the focused pane's border left/right, as tmux's resize-pane; J/K move spaces.
const REPEAT_MS = 1000;
const RESIZE = {
  H: script("pane-resize.sh", "left"),
  L: script("pane-resize.sh", "right"),
};

function lookup(e) {
  const m = e.modifiers ?? {};
  const plain = !m.control && !m.platform && !m.alt;
  if (plain && e.key_char && KEYS[e.key_char]) return KEYS[e.key_char];
  return KEYS[e.keystroke] ?? KEYS[e.key];
}

export default class Prefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  // Like tmux's `bind -r`: after a resize key the popup stays open, and more H/L
  // (shift optional) keep resizing until a pause of REPEAT_MS or any other key.
  keepRepeating(cx) {
    this.repeating = true;
    const gen = (this.gen = (this.gen ?? 0) + 1);
    cx.timer.after(REPEAT_MS, () => {
      if (this.gen === gen) closeOverlay(props().overlay);
    });
    cx.notify();
  }

  render() {
    const t = theme();
    return h_flex()
      .id("prefix")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (["shift", "control", "alt", "platform", "function"].includes(e.key)) return;
        cx.stop_propagation();
        const resize = RESIZE[(this.repeating ? e.key.toUpperCase() : e.key_char) ?? ""];
        if (resize) {
          resize();
          return this.keepRepeating(cx);
        }
        closeOverlay(props().overlay);
        if (e.key === "escape" || this.repeating) return;
        const action = lookup(e);
        if (action) action();
        else notify({ title: `ctrl-a ${e.keystroke}: not bound`, level: "warning", timeout: 2000 });
      })
      .size_full()
      .items_center()
      .justify_center()
      .gap(6)
      .bg(t.popover)
      .text_size(12)
      .child(div().px(6).rounded(4).bg(t.accent).text_color(t.accent_foreground).child(this.repeating ? "resize" : "ctrl-a"))
      .child(div().text_color(t.muted).child(this.repeating ? "HL" : "…"));
  }
}
