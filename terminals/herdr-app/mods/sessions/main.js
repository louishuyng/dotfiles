// Project picker for the Herdr app, the same routing as terminals/sesh/sesh-picker.sh:
// open tabs first, then zoxide folders not already open. A folder opens in the
// space named after its sesh.toml root (first match in file order), else after
// its own folder name; an existing tab already in that folder is reused.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { spaces, panes, run, exec, home, readTextFile, props, closeOverlay, openOverlay, theme, notify } from "herdr";

const VISIBLE = 12;
const PIXEL = "PxPlus IBM VGA 8x16";
const MONO = "JetBrains Mono";

// 7×7 pixel icons for section headers, drawn as divs like the machine monitor.
const FOLDER_ICON = ["###....", "#######", "#.....#", "#.....#", "#.....#", "#.....#", "#######"];
function pixelIcon(rows, color) {
  return v_flex().flex_none().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(2).h(2).when(ch === "#", (el) => el.bg(color))))));
}

async function readRoots() {
  const text = (await readTextFile(`${home()}/.config/sesh/sesh.toml`)) ?? "";
  const roots = [];
  let name = null;
  for (const line of text.split("\n")) {
    const n = line.match(/^\s*name\s*=\s*"(.+)"\s*$/);
    const p = line.match(/^\s*path\s*=\s*"(.+)"\s*$/);
    if (n) name = n[1];
    else if (p && name) {
      roots.push({ name, path: p[1].replace(/^~/, home()) });
      name = null;
    }
  }
  return roots;
}

const basename = (p) => p.replace(/\/+$/, "").split("/").pop();
const shortPath = (p) => p.split("/").filter(Boolean).slice(-2).join("/");
// fzf-like: every typed character appears in order.
const matches = (text, f) => {
  let i = 0;
  for (const ch of text.toLowerCase()) if (ch === f[i]) i++;
  return i === f.length;
};

export default class Sessions extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = 0;
    this.roots = [];
    this.paths = [];
    this.input = InputState.new({ placeholder: "Projects…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value().toLowerCase();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.rows()[this.at]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    cx.spawn(async (cx) => {
      this.roots = await readRoots();
      try {
        const r = await exec("zoxide", ["query", "-l"]);
        this.paths = r.stdout.split("\n").filter(Boolean);
      } catch {}
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  rows() {
    const open = new Set(panes().map((p) => p.cwd).filter(Boolean));
    const tabs = spaces().flatMap((s) =>
      s.tabs.map((t) => ({ kind: "tab", id: t.id, label: t.named ? `${s.name}:${t.index} ${t.name}` : `${s.name}:${t.index}`, active: s.active && t.active })),
    );
    const dirs = this.paths.filter((p) => !open.has(p)).map((p) => ({ kind: "dir", path: p, label: shortPath(p) }));
    const all = [...tabs, ...dirs];
    return this.filter ? all.filter((r) => matches(r.label, this.filter)) : all;
  }

  go(r) {
    if (!r) return;
    this.close();
    if (r.kind === "tab") return run("tab.select", { id: r.id });
    const root = this.roots.find((x) => r.path === x.path || r.path.startsWith(`${x.path}/`));
    const name = root?.name ?? basename(r.path);
    const space = spaces().find((s) => s.named && s.name === name);
    if (!space) return run("space.new", { name, folder: r.path, tab: basename(r.path) });
    const pane = panes().find((p) => p.cwd === r.path && space.tabs.some((t) => t.id === p.tab));
    if (pane) return run("tab.select", { id: pane.tab });
    run("tab.new", { space: space.id, folder: r.path, name: basename(r.path) });
  }

  closeTab(r) {
    if (r?.kind !== "tab") return;
    this.close();
    openOverlay({
      mod: "confirm",
      kind: "dialog",
      props: { title: `Close tab ${r.label}?`, detail: "Running work may stop.", command: { name: "tab.close", args: { id: r.id, confirmed: true } } },
    });
  }

  render() {
    const t = theme();
    const rows = this.rows();
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));
    // Draw a window of rows around the selection instead of scrolling ~250 zoxide entries.
    const start = Math.max(0, Math.min(this.at - VISIBLE + 1, rows.length - VISIBLE));
    const shown = rows.slice(Math.max(0, start), Math.max(0, start) + VISIBLE);

    // The typed letters, matched in order as `matches` does, drawn in the accent.
    const highlight = (text) => {
      const f = this.filter;
      const parts = [];
      let at = 0;
      for (const ch of text) {
        const hit = at < f.length && ch.toLowerCase() === f[at];
        if (hit) at++;
        const last = parts[parts.length - 1];
        if (last && last.hit === hit) last.text += ch;
        else parts.push({ hit, text: ch });
      }
      return h_flex().flex_1().min_w(0).overflow_hidden().children(
        parts.map((p) => div().flex_none().when(p.hit, (d) => d.text_color(t.accent).font_bold()).child(p.text)),
      );
    };

    const row = (r, i) => {
      const on = i === this.at;
      return h_flex()
        .id(`ss-${r.kind}-${r.id ?? r.path}`)
        .h(30)
        .pl(8)
        .pr(10)
        .gap(8)
        .items_center()
        .cursor_pointer()
        .border_l(3)
        .border_color(on ? t.accent : "#00000000")
        .when(on, (el) => el.bg(t.selected))
        .hover((s) => s.bg(on ? t.selected : t.hover))
        .on_click(() => this.go(r))
        .child(div().w(10).flex_none().text_color(t.accent).font_family(PIXEL).child(on ? "\u25b8" : ""))
        .child(div().w(16).flex_none().font_family("JetBrainsMono Nerd Font").text_color(r.kind === "tab" ? t.ansi6 : t.ansi3).child(r.kind === "tab" ? "\uf120" : "\uf0e7"))
        .child(div().flex_1().min_w(0).text_color(on || r.active ? t.foreground : t.muted).when(r.active, (d) => d.font_bold()).child(highlight(r.label)))
        .when(r.kind === "dir", (el) => el.child(div().max_w(260).truncate().text_size(11).text_color(t.dim).child(r.path.replace(home(), "~"))))
        .when(r.kind === "tab" && r.active, (el) => el.child(div().text_size(11).text_color(t.dim).child("current")));
    };
    const key = (k, what) =>
      h_flex().gap(4).items_center()
        .child(div().px(4).border_1().border_color(t.border).bg(t.raised).text_color(t.muted).child(k))
        .child(div().text_color(t.dim).child(what));

    return v_flex()
      .id("sessions")
      .w_full()
      .min_h(0)
      .p(14)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .font_family(MONO)
      .on_key_down((e, cx) => {
        const k = e.key;
        const ctrl = e.modifiers.control;
        if (k === "escape") return this.close();
        if (k === "down" || k === "tab" || (ctrl && (k === "n" || k === "j"))) this.at = Math.min(this.at + 1, rows.length - 1);
        else if (k === "up" || (ctrl && (k === "p" || k === "k"))) this.at = Math.max(this.at - 1, 0);
        else if (ctrl && k === "d") return this.closeTab(rows[this.at]);
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex().items_center().font_family(PIXEL).text_size(15)
          .child(div().mr(8).child(pixelIcon(FOLDER_ICON, t.muted)))
          .child(div().flex_1().text_color(t.muted).child("PROJECTS"))
          .child(div().text_size(13).text_color(t.dim).child(`${rows.length}`)),
      )
      .child(
        h_flex().h(34).px(10).gap(8).items_center().border_1().border_color(t.accent).bg(t.background)
          .child(div().text_color(t.accent).font_bold().child(">"))
          .child(Input.new(this.input).flex_1().h_full().text_size(13).text_color(t.foreground)),
      )
      .child(v_flex().gap(1).children(shown.map((r, i) => row(r, i + Math.max(0, start)))))
      .when(!rows.length, (el) => el.child(div().py(8).text_color(t.dim).child("No match. Esc to close.")))
      .child(
        h_flex().gap(14).pt(4).border_t(1).border_color(t.border).text_size(11)
          .child(key("\u21b5", "open"))
          .child(key("ctrl-j/k", "move"))
          .child(key("ctrl-d", "close tab"))
          .child(key("esc", "cancel")),
      );
  }
}
