// Retro spaces list for layouts/retro.json: pixel-font headers, spaces grouped by machine.
// Click a space to show it; `+` on a machine header makes a space there.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, machines, run, theme, shared, setShared, openOverlay } from "herdr";
import { svg } from "gpui-kit";

const PIXEL = "PxPlus IBM VGA 8x16";

// Pixel icons for section headers (two stacked windows here), drawn as divs like the machine monitor.
const SPACES_ICON = ["..#######", "..#.....#", "#######.#", "#######.#", "#.....###", "#.....#..", "#.....#..", "#######.."];
function pixelIcon(rows, color) {
  return v_flex().flex_none().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(2).h(2).when(ch === "#", (el) => el.bg(color))))));
}

// Space colors, shared with Herdr's own mods (mods/picker): kept by space id in shared
// "space.colors", each new space getting the least-used color. Same algorithm and order
// as Herdr's, so every mod agrees; the shipped spaces mod that normally assigns them isn't
// in this layout.
const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };
const PROJECT_COLORS = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
function spaceColors() {
  const ids = new Set(spaces().map((p) => p.id));
  const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
  let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
  for (const p of spaces()) {
    if (kept[p.id] || p.name === "~") continue;
    const uses = (c) => Object.values(kept).filter((v) => v === c).length;
    kept[p.id] = PROJECT_COLORS.reduce((best, c) => (uses(c) < uses(best) ? c : best));
    changed = true;
  }
  if (changed) setShared("space.colors", kept);
  return kept;
}
function spaceColor(t, p, colors) {
  if (p.name === "~") return t.dim;
  const c = colors[p.id] ?? PROJECT_COLORS[0];
  return c.startsWith("#") ? c : (MARK[c] ?? t[c]);
}
const TITLE_H = 32;
const HEAD_H = 30;
const ROW_H = 30;

function sectionHead(t, title, right) {
  return h_flex()
    .h(TITLE_H)
    .px(12)
    .gap(8)
    .items_center()
    .font_family(PIXEL)
    .text_size(15)
    .text_color(t.muted)
    .child(pixelIcon(SPACES_ICON, t.muted))
    .child(div().flex_1().child(title))
    .child(right ?? div());
}

// A tiny pixel monitor in the machine's color.
function monitor(color) {
  const px = (w, h, bg) => div().w(w).h(h).bg(bg);
  return v_flex()
    .flex_none()
    .items_center()
    .child(div().w(14).h(9).p(2).bg(color).child(px(10, 5, "#00000099")))
    .child(px(4, 2, color))
    .child(px(10, 1, color));
}

function machineHead(t, label, count, color, onAdd) {
  return h_flex()
    .h(HEAD_H)
    .px(12)
    .gap(8)
    .items_center()
    .font_family(PIXEL)
    .text_size(15)
    .child(monitor(color))
    .child(div().text_color(color).child(label.toUpperCase()))
    .child(div().flex_1().h(1).bg(color).opacity(0.5))
    .child(div().text_color(t.foreground).child(count))
    .when(Boolean(onAdd), (el) =>
      el.child(div().id(`add-${label}`).text_color(t.accent).cursor_pointer().hover((s) => s.text_color(t.foreground)).on_click(onAdd).child("+")),
    );
}

export default class RetroSpaces extends View {
  render() {
    const t = theme();
    const all = spaces();
    const groups = [null, ...machines().map((m) => m.name).filter(Boolean)].map((m) => ({ m, list: all.filter((s) => s.machine === m) }));
    const colors = [t.ansi1, t.accent, t.ansi6, t.ansi5, t.ansi2];
    const marks = spaceColors();

    // The block is only as tall as its list, so Agents sits right below it.
    const height = 6 + TITLE_H + groups.length * HEAD_H + all.length * ROW_H + 12 + ((this.width ?? 300) < 160 ? 28 : 0);
    if (height !== this.height) {
      this.height = height;
      run("layout.resize", { id: "spaces", px: Math.min(height, 420) });
    }

    // Selected: the space's color as the bar, a faint tint of it behind the row and a
    // marker; others light up on hover.
    const tint = (c) => (/^#[0-9a-f]{6}$/i.test(c) ? `${c}2e` : t.selected);
    const row = (s) => {
      const color = spaceColor(t, s, marks);
      return h_flex()
        .id(`sp-${s.id}`)
        .h(ROW_H)
        .mx(12)
        .pl(8)
        .pr(8)
        .gap(6)
        .items_center()
        .font_family(PIXEL)
        .text_size(15)
        .cursor_pointer()
        .border_l(3)
        .border_color(s.active ? color : "#00000000")
        .when(s.active, (el) => el.bg(tint(color)))
        .hover((el) => el.bg(s.active ? tint(color) : t.hover).text_color(t.foreground))
        .text_color(s.active ? t.foreground : t.muted)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", (_e, cx) => {
          cx.stop_propagation();
          openOverlay({ mod: "retro-menu", kind: "popup", width: 240, height: 230, props: { tab: "space", target: { id: s.id } } });
        })
        .child(div().w(10).flex_none().text_color(color).child(s.active ? "\u25b8" : ""))
        .child(div().flex_1().truncate().when(s.active, (d) => d.font_bold()).child(s.name))
        .when(s.tabs.length > 1, (el) => el.child(div().text_size(12).text_color(t.dim).child(String(s.tabs.length))))
        .when(Boolean(s.status), (el) => el.child(div().text_color(t[s.status] ?? t.dim).child(s.status === "working" ? "*" : "!")));
    };

    // Collapsed sidebar (Herdr folds it to a ~76px rail): a pixel tile per space, its
    // initial in the space's color, framed when shown.
    const narrow = (this.width ?? 300) < 160;
    const tile = (s) => {
      const color = spaceColor(t, s, marks);
      return h_flex()
        .id(`sp-${s.id}`)
        .h(ROW_H)
        .justify_center()
        .items_center()
        .cursor_pointer()
        .on_click(() => run("space.select", { id: s.id }))
        .child(
          h_flex().size(26).items_center().justify_center().font_family(PIXEL).text_size(15)
            .bg(s.active ? tint(color) : t.raised).border_2().border_color(s.active ? color : t.border)
            .text_color(color).hover((el) => el.border_color(color))
            .child(([...s.name.replace(/^\./, "")][0] ?? "?").toUpperCase()),
        );
    };

    return v_flex()
      .id("retro-spaces")
      .size_full()
      .pt(6)
      .bg(t.chrome)
      .on_size_change((size, cx) => {
        if ((size.width < 160) !== ((this.width ?? 300) < 160)) cx.notify();
        this.width = size.width;
      })
      .child(
        narrow
          ? v_flex().items_center()
              // On macOS the brand block hides its toggle in the rail (the window buttons sit
              // there), so the rail gets its own way back: the width lx-chrome saved on collapse.
              .child(div().id("sp-expand").size(28).flex().items_center().justify_center().cursor_pointer().text_color(t.muted)
                .hover((s) => s.bg(t.hover).text_color(t.accent))
                .on_click(() => {
                  setShared("sidebar.collapsed", false);
                  run("layout.resize", { id: "sidebar", px: shared("sidebar.width") ?? 268 });
                })
                .child(svg("mods/workspace-chrome/chevron-right.svg").size(16)))
              .child(h_flex().h(TITLE_H).justify_center().items_center().child(div().id("sp-new").cursor_pointer().text_color(t.muted).font_family(PIXEL).text_size(15).hover((s) => s.text_color(t.accent)).on_click(() => run("space.new", { machine: "" })).child("+")))
          : sectionHead(t, "SPACES", div().id("sp-new").cursor_pointer().text_color(t.muted).hover((s) => s.text_color(t.accent)).on_click(() => run("space.new", { machine: "" })).child("+")),
      )
      .child(
        v_flex()
          .id("sp-list")
          .flex_1()
          .min_h(0)
          .overflow_y_scrollbar()
          .children(
            groups.flatMap(({ m, list }, i) => [
              narrow
                ? h_flex().h(HEAD_H).justify_center().items_center().child(monitor(colors[i % colors.length]))
                : machineHead(t, m ?? "this machine", list.length, colors[i % colors.length], () => run("space.new", { machine: m ?? "" })),
              ...list.map(narrow ? tile : row),
            ]),
          ),
      );
  }
}
