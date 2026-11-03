// pixel-chrome: Herdr's shipped `workspace-chrome` mod (0.1.11, Apache-2.0), changed so the
// sidebar's header shows, in place of Herdr's logo and name, only whether agents wait for you
// (a pixel bell and how many), and its search button opens pixel-picker. The footer is Herdr's.
// Glyphs search/sidebar/settings/plus are Lucide (ISC, LICENSE-Lucide.txt); bell.svg is new.

import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, props, window, shared, setShared, updates, layout, agents } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// To the rail (on macOS wide enough for the traffic lights), or back to the width it had.
function toggleSidebar() {
  const width = find(layout(), "sidebar")?.size?.px;
  if (!narrow()) setShared("sidebar.width", width);
  // Mods edited before the rail went by width still read the flag.
  setShared("sidebar.collapsed", !narrow());
  run("layout.resize", { id: "sidebar", px: narrow() ? (shared("sidebar.width") ?? 268) : window()?.platform === "macos" ? 76 : 44 });
}

export default class WorkspaceChrome extends View {
  button(id, label, action) {
    const t = theme();
    return div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.muted).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(action).child(label);
  }
  waiting(t) {
    const list = agents().filter(a => a.status === "blocked" || a.status === "done");
    if (!list.length) return div();
    const rank = a => (a.status === "blocked" ? 0 : 1);
    const first = [...list].sort((a, b) => rank(a) - rank(b) || b.seq - a.seq)[0];
    const tone = list.some(a => a.status === "blocked") ? t.blocked : t.done;
    return h_flex().id("waiting").h(24).px(7).gap(6).flex_none().items_center().rounded(6).cursor_pointer()
      .text_color(tone).hover(s => s.bg(t.hover))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(() => run("pane.focus", { pane: first.pane }))
      .child(svg("mods/pixel-chrome/bell.svg").size(14).flex_none())
      .child(div().font_semibold().child(String(list.length)));
  }
  render() {
    const t = theme();
    const collapsed = narrow();
    if (props()?.footer) {
      const row = (id, icon, label, dim, action) => h_flex().id(id).h(28).px(8).gap(9).items_center().rounded(8)
        .text_color(dim ? t.dim : t.muted).hover(s => s.bg(t.hover).text_color(t.foreground)).cursor_pointer()
        .on_click(action).child(svg(`mods/pixel-chrome/${icon}.svg`).size(14))
        .when(!collapsed, el => el.child(label));
      return v_flex().size_full().bg(t.chrome).border_t(1).border_color(t.border).px(8).pt(4).pb(8).text_size(13)
        .child(row("settings", "settings", "Settings", false, () => run("app.settings"))
          .when(Boolean(updates().app.ready), el => el.child(div().size(6).rounded_full().bg(t.accent))))
        .child(row("machine", "plus", "Add machine", true, () => run("mod.open", { name: "machine-add" })));
    }
    return h_flex().size_full().bg(t.chrome).pl(collapsed ? 6 : 14).pr(10).gap(4).items_center().text_size(13.5)
      .when(window()?.platform === "macos" && !collapsed, el => el.pl(76))
      // pixel-chrome: in place of Herdr's logo and name, only whether agents wait for you
      // (blocked, or done while you weren't looking): a pixel bell and how many, nothing when
      // none. A click shows the most urgent one. Search opens pixel-picker.
      .when(!collapsed, el => el.child(h_flex().flex_1().items_center().child(this.waiting(t))))
      .when(!collapsed, el => el.child(this.button("search", svg("mods/pixel-chrome/search.svg").size(15), () => run("mod.open", { name: "pixel-picker" }))))
      // On the macOS rail the traffic lights fill the row; the agents list's » unfolds it.
      .when(!(collapsed && window()?.platform === "macos"), el => el.child(this.button("sidebar-toggle", svg("mods/pixel-chrome/sidebar.svg").size(15), toggleSidebar)));
  }
}
