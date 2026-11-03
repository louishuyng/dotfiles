import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, openOverlay, theme, window, shared, layout, settings } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class Tabs extends View {
  init() {
    this.pressed = null;
    this.panels = JSON.parse(localStorage.getItem("panels") ?? "{}");
  }

  // The side panel is remembered per space: switching shows that space's choice
  // (closed if it never had one), and opening or closing it records it.
  syncPanel(space, panel, body, enabled) {
    if (!space || !panel) return;
    const now = panel.hidden ? null : body?.active ?? null;
    if (space.id !== this.space) {
      const first = this.space === undefined;
      this.space = space.id; this.pending = null;
      if (!(first && !(space.id in this.panels))) {
        const stored = this.panels[space.id] ?? null, want = enabled.includes(stored) ? stored : null;
        if (want !== now) {
          this.pending = { want, until: Date.now() + 1000 };
          if (want) { run("layout.select", { stack: "panel-body", child: want }); run("layout.show", { id: "panel" }); }
          else run("layout.hide", { id: "panel" });
          return;
        }
      }
    }
    // Until the restore lands (or something else won), the old state isn't a choice.
    if (this.pending) {
      if (this.pending.want !== now && Date.now() < this.pending.until) return;
      this.pending = null;
    }
    if (this.panels[space.id] === now) return;
    this.panels[space.id] = now;
    localStorage.setItem("panels", JSON.stringify(this.panels));
  }

  render() {
    const t = theme();
    const space = spaces().find(p => p.active);
    const shown = space?.tabs ?? [];
    const stop = (_e, cx) => cx.stop_propagation();
    const button = (id, label, action) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action).child(label);
    // tmux window-status: " 1 name" plain text, grey; the active one bold purple
    // (terminals/tmux/plugins/dark.conf). No pills, icons or close buttons.
    const mono = settings().font_family;
    const item = (c, i) => {
      const program = panes().find(p => p.tab === c.id && p.program?.agent)?.program ?? panes().find(p => p.tab === c.id)?.program;
      const name = c.named ? c.name : program?.name?.toLowerCase() ?? "fish";
      const color = c.status === "blocked" ? t.blocked : c.status === "done" ? t.done : c.active ? t.ansi5 : t.muted;
      return h_flex().id(`tab-${c.id}`).h_full().px(7).gap(6).items_center().flex_none().text_size(12).font_family(mono)
        .text_color(color).when(c.active, el => el.font_bold())
        .hover(s => s.text_color(t.foreground))
        .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.pressed = i; if (e.click_count === 2) run("tab.rename", { id: c.id }); })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from !== null && from !== i) run("tab.move", { id: shown[from].id, index: space.tabs.findIndex(x => x.id === c.id) + 1 });
          else run("tab.select", { id: c.id });
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "retro-menu", kind: "popup", width: 240, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .child(`${c.index} ${name}${c.zoomed ? " \u{f0293}" : ""}`)
        .when(c.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(11).flex_none().text_color(t.working).spin(900)));
    };
    // tmux status-left: the session (space) name in green, its pane count when split.
    const paneCount = panes().filter(p => shown.some(c => c.id === p.tab && c.active)).length;
    // Text padding only when the shown tab is split: Herdr pads every pane alike, so the
    // layout's terminal_padding ([sides, top/bottom]) is switched as the pane count changes.
    // layout.set rewrites layouts/retro.json, so only the padding values churn in git.
    const split = paneCount > 1 && !shown.find(c => c.active)?.zoomed;
    // The work area's margin and the pane frame go too, so a single or zoomed pane runs
    // edge to edge with no focus highlight.
    const pad = split ? [8, 0] : [0, 0];
    const margin = split ? 6 : 0;
    const frame = split ? 1 : 0;
    const tree = layout();
    const workBody = find(tree, "work-body");
    const paneLook = find(tree, "main")?.content?.pane;
    const stale = (n) => JSON.stringify(n.terminal_padding) !== JSON.stringify(pad) || (find(n, "work-body").padding ?? 0) !== margin
      || (find(n, "main").content.pane.border?.width ?? 0) !== frame || (find(n, "main").content.pane.focus?.width ?? 0) !== frame;
    if (tree && workBody && paneLook && stale(tree)) {
      const next = JSON.parse(JSON.stringify(tree));
      next.terminal_padding = pad;
      find(next, "work-body").padding = margin;
      const look = find(next, "main").content.pane;
      look.border = { ...look.border, width: frame };
      look.focus = { ...look.focus, width: frame };
      run("layout.set", { layout: next });
    }
    const session = h_flex().flex_none().h_full().pr(6).gap(6).items_center().text_size(12).font_family(mono)
      .child(div().text_color(t.ansi2).font_bold().child(space?.name ?? ""))
      .when(paneCount > 1, el => el.child(div().text_color(t.dim).child(`\u{f0f58} ${paneCount}`)))
      .child(div().text_color(t.border).child("│"));
    const root = layout(), sidebar = find(root, "sidebar"), w = window();
    // Old saved rails and a dragged-narrow sidebar can be smaller than the window buttons.
    const lightsPadding = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - (sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0))
      : 10;
    const panel = find(root, "panel"), body = find(root, "panel-body");
    const enabled = shared("workspace.panels") ?? ["files", "changes"];
    this.syncPanel(space, panel, body, enabled);
    const panelButton = (id, label, icon) => {
      const on = panel && !panel.hidden && body?.active === id;
      return h_flex().id(`panel-${id}`).h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(on ? t.selected : t.chrome).text_color(on ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
        .on_click(() => {
          if (on) run("layout.hide", { id: "panel" });
          else { run("layout.select", { stack: "panel-body", child: id }); run("layout.show", { id: "panel" }); }
        }).child(svg(icon).size(14)).child(label);
    };
    return h_flex().size_full().min_w(0).px(10).pl(lightsPadding).gap(3).items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel(e => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .when(Boolean(space), el => el.child(session))
      .child(h_flex().id("tab-scroll").flex_1().min_w(0).h_full().items_center().overflow_x_scrollbar().children(shown.map(item)))
      .child(button("tab-new", "+", () => openOverlay({ mod: "retro-new-menu", kind: "popup", width: 290, height: 540 })))
      .when(enabled.includes("files"), el => el.child(panelButton("files", "Files", "mods/files/file.svg")))
      .when(enabled.includes("changes"), el => el.child(panelButton("changes", "Changes", "mods/changes/changes.svg")))
      .when(w?.buttons, el => el.child(button("minimize", w.platform === "windows" ? svg("mods/tabs/win-min.svg").size(16) : "−", () => run("window.minimize")))
        .child(button("maximize", w.platform === "windows" ? svg(`mods/tabs/${w.maximized ? "win-restore" : "win-max"}.svg`).size(16) : "□", () => run("window.maximize")))
        .child(button("close-window", w.platform === "windows" ? svg("mods/tabs/win-close.svg").size(16) : svg("mods/pane/close.svg").size(13), () => run("window.close"))));
  }
}
