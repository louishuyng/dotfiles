import { View, div, svg, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, spaces, panes, knownAgents, run, openOverlay, closeOverlay, props, window, keys, shared, setShared } from "herdr";

// The last agents each machine reported, shown at once while knownAgents() checks again.
const KNOWN = "new-menu.agents";

// 7×7 pixel icons for section headers, drawn as divs like the machine monitor.
const AGENT_ICON = ["...#...", ".#####.", ".#.#.#.", ".#####.", "#######", ".#####.", ".#...#."];
function pixelIcon(rows, color) {
  return v_flex().flex_none().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(2).h(2).when(ch === "#", (el) => el.bg(color))))));
}

function shortcut(name) {
  const k = keys().find(b => b.section === "global" && b.action === name);
  if (!k?.keys.trim()) return "";
  const mac = window()?.platform === "macos";
  const names = mac ? { ctrl: "⌃", alt: "⌥", shift: "⇧", cmd: "⌘", fn: "fn" } : { ctrl: "Ctrl", alt: "Alt", shift: "Shift", cmd: "Super", fn: "Fn" };
  const alias = { secondary: mac ? "cmd" : "ctrl", super: "cmd", win: "cmd" };
  return k.keys.trim().split(/\s+/).map(stroke => {
    const parts = stroke.split("-");
    let key = parts.pop();
    if (key === "") { key = "-"; parts.pop(); }
    const held = new Set(parts.map(m => alias[m.toLowerCase()] ?? m.toLowerCase()));
    if (/^[A-Z]$/.test(key)) held.add("shift");
    const label = key.length === 1 ? key.toUpperCase() : key[0].toUpperCase() + key.slice(1).toLowerCase();
    return [...Object.keys(names).filter(m => held.has(m)).map(m => names[m]), label].join(mac ? "" : "+");
  }).join(" ");
}

export default class NewMenu extends View {
  init(_props, cx) {
    const machine = spaces().find(s => s.active)?.machine;
    const where = machine ?? "";
    this.agents = shared(KNOWN)?.[where] ?? [];
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.spawn(async cx => {
      try {
        this.agents = await knownAgents({ on: machine });
        setShared(KNOWN, { ...shared(KNOWN), [where]: this.agents });
      }
      catch { this.failed = true; }
      cx.notify();
    });
  }
  // Rows in the project picker's look (mods/sessions). this.rows collects them in order
  // each render so ↑/↓/Enter can drive them.
  row(id, icon, name, action, hint = "", enabled = true) {
    const t = theme();
    const i = this.rows.length;
    this.rows.push(enabled ? action : null);
    const on = i === this.at && enabled;
    const run_ = () => { if (enabled) { closeOverlay(props().overlay); action(); } };
    return h_flex().id(id).h(30).pl(6).pr(10).gap(8).items_center().flex_none()
      .border_l(3).border_color(on ? t.accent : "#00000000")
      .text_color(!enabled ? t.dim : on ? t.foreground : t.muted)
      .when(on, el => el.bg(t.selected))
      .when(enabled, el => el.hover(s => s.bg(t.selected).text_color(t.foreground)).on_hover((h, cx) => { if (h) { this.at = i; cx.notify(); } }))
      .on_click(run_)
      .child(div().w(10).flex_none().text_color(t.accent).font_family("PxPlus IBM VGA 8x16").child(on ? "\u25b8" : ""))
      .child(icon).child(div().flex_1().child(name))
      .when(Boolean(hint), el => el.child(div().px(4).border_1().border_color(t.border).bg(t.raised).text_size(11).text_color(t.muted).child(hint)));
  }
  section(title) {
    const t = theme();
    return h_flex().px(12).pt(8).pb(4).gap(8).items_center().font_family("PxPlus IBM VGA 8x16").text_size(13).text_color(t.muted)
      .child(pixelIcon(AGENT_ICON, t.muted)).child(title);
  }
  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const installed = this.agents.filter(a => a.installed);
    const choices = [...installed, ...this.agents.filter(a => !a.installed).slice(0, 2)];
    this.rows = [];
    this.at = this.at ?? 0;
    return v_flex().min_h(0).w_full().h(Math.min(520, 200 + Math.max(1, choices.length) * 30)).bg(t.popover).py(6).text_size(13).font_family("JetBrains Mono")
      .id("new-menu").track_focus(this.handle)
      .on_key_down((e, cx) => {
        const n = this.rows.length, step = (d) => { let i = this.at; do i = (i + d + n) % n; while (!this.rows[i] && i !== this.at); this.at = i; cx.notify(); };
        if (e.key === "down" || (e.modifiers.control && e.key === "j")) return step(1);
        if (e.key === "up" || (e.modifiers.control && e.key === "k")) return step(-1);
        if (e.key === "enter" && this.rows[this.at]) { closeOverlay(props().overlay); return this.rows[this.at](); }
        if (e.key === "escape") return closeOverlay(props().overlay);
        if (e.modifiers.control || e.modifiers.platform || e.modifiers.alt) return;
        const agent = /^[1-9]$/.test(e.key) ? installed[Number(e.key) - 1] : null;
        if (!agent) return;
        closeOverlay(props().overlay);
        run("tab.new", { name: agent.name, space: space?.id, argv: agent.run });
      })
      .child(this.row("terminal", svg("icons/shell.svg").size(14), "Terminal", () => run("tab.new", { space: space?.id }), shortcut("tab.new")))
      .child(this.section("START AN AGENT"))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar()
        .children(choices.map((a, i) => this.row(a.key, a.tint ? svg(a.icon).size(14).text_color(t.foreground) : image(a.icon).size(14), a.name,
          () => run("tab.new", { name: a.name, space: space?.id, argv: a.run }), a.installed ? (i < 9 ? String(i + 1) : "") : "not installed", a.installed)))
        .when(this.agents.length === 0, el => el.child(div().px(12).py(6).text_color(t.dim).child(this.failed ? "Could not load agents" : "Checking installed agents…"))))
      .child(div().h(1).mx(8).my(5).bg(t.border))
      .child(this.row("space", div().w(14).child("+"), "New space", () => run("space.new"), shortcut("space.new")))
      .child(this.row("worktree", svg("mods/workspace-chrome/branch.svg").size(14), "New worktree…", () => openOverlay({ mod: "worktree", kind: "dialog", width: 460, height: 280, props: { space: space?.id, folder: panes().find(p => p.focused)?.cwd, action: "new" } }), "", Boolean(space)))
      .child(this.row("worktree-open", svg("mods/workspace-chrome/branch.svg").size(14), "Open worktree\u2026", () => openOverlay({ mod: "worktree", kind: "dialog", width: 560, height: 480, props: { space: space?.id, folder: panes().find(p => p.focused)?.cwd, action: "open" } }), "", Boolean(space)));
  }
}
