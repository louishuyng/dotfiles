// Retro agent cards for layouts/retro.json: one card per agent, grouped by machine,
// a pixel sprite per program and a status badge. Click a card to focus that agent.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, spaces, machines, run, theme, setAgentOrder } from "herdr";

const PIXEL = "PxPlus IBM VGA 8x16";

// 7×7 pixel icons for section headers, drawn as divs like the machine monitor.
const AGENT_ICON = ["...#...", ".#####.", ".#.#.#.", ".#####.", "#######", ".#####.", ".#...#."];
function pixelIcon(rows, color) {
  return v_flex().flex_none().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(2).h(2).when(ch === "#", (el) => el.bg(color))))));
}

// 12×10 pixel art, one letter per palette color, drawn as divs (mod images don't load
// from the symlinked mod folder).
const SPRITES = {
  crab: {
    pal: { a: "#d97757", b: "#1a0f0a" },
    rows: ["............", "..aaaaaaaa..", "..aaaaaaaa..", "..abaaaaba..", "aaaaaaaaaaaa", "aaaaaaaaaaaa", "..aaaaaaaa..", "..aaaaaaaa..", "..a.a..a.a..", "..a.a..a.a.."],
  },
  robot: {
    pal: { a: "#5a6670", b: "#b8c4cc", c: "#3ed49c", d: "#0b0e0d" },
    rows: [".....aa.....", ".....aa.....", "..bbbbbbbb..", ".bbbbbbbbbb.", ".bbccddccbb.", ".bbccddccbb.", ".bbbbbbbbbb.", ".bbaaaaaabb.", "..bbbbbbbb..", "...aa..aa..."],
  },
  duck: {
    pal: { a: "#f2c94c", b: "#ffffff", c: "#1a1a1a", d: "#e8833a" },
    rows: ["....aaaa....", "...aaaaaa...", "...aabcaadd.", "...aaaaaadd.", "....aaaa....", "a..aaaaaaa..", "aaaaaaaaaaa.", ".aaaaaaaaaa.", "..aaaaaaaa..", "....d..d...."],
  },
};
const BY_PROGRAM = { claude: "crab", codex: "robot" };
const PX = 4;
const STARS = [[6, 6], [58, 9], [30, 4], [48, 20], [14, 22]];

function spriteFor(a) {
  const id = `${a.app ?? ""} ${a.program?.name ?? ""}`.toLowerCase();
  const key = Object.keys(BY_PROGRAM).find((k) => id.includes(k));
  return SPRITES[key ? BY_PROGRAM[key] : "duck"];
}

function pixels({ pal, rows }) {
  return v_flex().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(PX).h(PX).when(ch in pal, (el) => el.bg(pal[ch]))))));
}

// A tiny pixel monitor in the machine's color (same as retro-spaces).
function monitor(color) {
  const px = (w, h, bg) => div().w(w).h(h).bg(bg);
  return v_flex()
    .flex_none()
    .items_center()
    .child(div().w(14).h(9).p(2).bg(color).child(px(10, 5, "#00000099")))
    .child(px(4, 2, color))
    .child(px(10, 1, color));
}

// Night scene: stars, a striped ground, the sprite (bobbing while working) and a bubble.
function scene(t, a) {
  const bubble = { idle: "z", blocked: "!", done: "✓" }[a.status];
  const bubbleColor = { idle: t.muted, blocked: t.blocked, done: t.done }[a.status];
  return div()
    .relative()
    .w(72)
    .h(64)
    .flex_none()
    .overflow_hidden()
    .bg("#1b1840")
    .border_1()
    .border_color(t.border)
    .children(STARS.map(([x, y]) => div().absolute().left(x).top(y).w(2).h(2).bg("#fff3c4").opacity(0.7)))
    .child(div().absolute().left(0).right(0).bottom(0).h(10).bg("#3a2d6b"))
    .child(div().absolute().left(0).right(0).bottom(6).h(2).bg("#6a4fb0"))
    .child(
      div()
        .absolute()
        .left(12)
        .top(14)
        .child(pixels(spriteFor(a)))
        .when(a.status === "working", (el) => el.loop("top", { from: 14, to: 9, period: 500 })),
    )
    .when(Boolean(bubble), (el) =>
      el.child(
        div().absolute().right(4).top(3).px(2).border_1().border_color(bubbleColor).text_color(bubbleColor).font_family(PIXEL).text_size(10).child(bubble)
          .when(a.status === "blocked", (b) => b.loop("opacity", { from: 0.3, to: 1, period: 700 })),
      ),
    );
}

export default class RetroAgents extends View {
  render() {
    const t = theme();
    const list = agents();
    const machineOf = Object.fromEntries(spaces().map((s) => [s.id, s.machine]));
    const names = [null, ...machines().map((m) => m.name).filter(Boolean)];
    // Same machine colors, in the same order, as retro-spaces.
    const colors = [t.ansi1, t.accent, t.ansi6, t.ansi5, t.ansi2];
    const colorOf = (m) => colors[names.indexOf(m) % colors.length];
    const groups = names
      .map((m) => ({ m, list: list.filter((a) => (machineOf[a.space] ?? null) === m) }))
      .filter((g) => g.list.length);
    setAgentOrder(groups.flatMap((g) => g.list.map((a) => a.address)));
    const busy = list.filter((a) => a.status === "working").length;

    const head = h_flex()
      .h(32)
      .px(12)
      .gap(8)
      .items_center()
      .font_family(PIXEL)
      .text_size(15)
      .text_color(t.muted)
      .child(pixelIcon(AGENT_ICON, t.muted))
      .child(div().flex_1().child("AGENTS"))
      .child(div().text_color(busy ? t.working : t.muted).child(`${busy} BUSY`));

    const machineHead = (m, g) =>
      h_flex()
        .h(30)
        .px(12)
        .gap(8)
        .items_center()
        .font_family(PIXEL)
        .text_size(15)
        .child(monitor(colorOf(m)))
        .child(div().text_color(colorOf(m)).child((m ?? "this machine").toUpperCase()))
        .child(div().flex_1().h(1).bg(colorOf(m)).opacity(0.5))
        .child(div().text_color(t.foreground).child(`${g.filter((a) => a.status === "working").length}/${g.length}`));

    const badge = (a) =>
      div()
        .px(5)
        .border_1()
        .border_color(t[a.status] ?? t.dim)
        .text_color(t[a.status] ?? t.dim)
        .font_family(PIXEL)
        .text_size(13)
        .child(a.status.toUpperCase())
        .when(a.status === "working", (el) => el.loop("opacity", { from: 0.4, to: 1, period: 1200 }));

    const card = (a) =>
      h_flex()
        .id(`ag-${a.address}`)
        .mx(10)
        .p(6)
        .gap(10)
        .items_center()
        .bg(t.raised)
        .border_2()
        .border_color(a.focused ? t.accent : a.status === "blocked" ? t.blocked : t.border)
        .cursor_pointer()
        .hover((s) => s.border_color(t.accent))
        .on_click(() => run("agent.focus", { terminal: a.address }))
        .child(scene(t, a))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .gap(4)
            .child(h_flex().child(badge(a)))
            .child(div().truncate().font_family(PIXEL).text_size(16).text_color(t.foreground).child(a.space_name))
            .child(div().truncate().text_size(12).text_color(t.muted).child(a.title || `tab ${a.tab_name}`)),
        );

    // Collapsed sidebar: just each agent's scene, framed in its status color.
    const narrow = (this.width ?? 300) < 160;
    const mini = (a) =>
      h_flex()
        .id(`ag-${a.address}`)
        .justify_center()
        .cursor_pointer()
        .on_click(() => run("agent.focus", { terminal: a.address }))
        .child(div().border_2().border_color(a.focused ? t.accent : a.status === "blocked" ? t.blocked : t.border).child(scene(t, a)));

    return v_flex()
      .id("retro-agents")
      .size_full()
      .pt(6)
      .bg(t.chrome)
      .border_t(1)
      .border_color(t.border)
      .on_size_change((size, cx) => {
        if ((size.width < 160) !== ((this.width ?? 300) < 160)) cx.notify();
        this.width = size.width;
      })
      .child(
        narrow
          ? h_flex().h(32).justify_center().items_center().font_family(PIXEL).text_size(15).text_color(busy ? t.working : t.muted).child(String(busy))
          : head,
      )
      .child(
        v_flex()
          .id("ag-list")
          .flex_1()
          .min_h(0)
          .overflow_y_scrollbar()
          .gap(8)
          .pb(10)
          .when(!groups.length && !narrow, (el) =>
            el.child(div().px(12).pt(6).text_size(13).text_color(t.dim).child("No agents yet. Start one with + in the tab bar.")),
          )
          .children(
            groups.flatMap(({ m, list: g }) =>
              narrow
                ? [h_flex().h(26).justify_center().items_center().child(monitor(colorOf(m))), ...g.map(mini)]
                : [machineHead(m, g), ...g.map(card)],
            ),
          ),
      );
  }
}
