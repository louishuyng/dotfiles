// My open GitHub PRs and the active Jira sprint, each on its own board. Data and actions go
// through scripts/issues.sh, so they can be tried from a shell and logins stay in each CLI.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, exec, home, props, closeOverlay, theme } from "herdr";

const SCRIPT = `${home()}/.dotfiles/terminals/herdr-app/scripts/issues.sh`;
const PIXEL = "PxPlus IBM VGA 8x16";
const MONO = "JetBrains Mono";
const SHOWN = 4; // cards that fit a column; keyboard moves keep the selection inside them
const CACHE = "issues.v2"; // bump when the item shape changes
const VIEW = "issues.view";

const BOARDS = {
  github: {
    label: "GitHub",
    tag: "GH",
    columns: [
      { label: "CI failed", test: (i) => i.reasons.includes("ci") },
      { label: "Created", test: (i) => i.reasons.includes("created") },
      { label: "Review requested", test: (i) => i.reasons.includes("review") },
      { label: "Assigned to me", test: (i) => i.reasons.includes("assigned") },
    ],
  },
  // Board 145's columns and the statuses mapped to each (Board settings > Columns); a card
  // dropped on a column moves to its `to` status.
  jira: {
    label: "Jira",
    tag: "JIRA",
    columns: [
      { label: "To Do", to: "Open", statuses: ["Epic Scoping", "Product Refinement", "Eng Refinement", "Open", "Reopened", "Rework", "Ready for Dev", "Wireframing", "Analysis"] },
      { label: "On Hold", to: "On Hold", statuses: ["On Hold"] },
      { label: "In Progress", to: "In Progress", statuses: ["In Progress"] },
      { label: "In Review", to: "In Review", statuses: ["In Review"] },
      { label: "In Testing", to: "In Testing", statuses: ["In Testing"] },
      { label: "Done", to: "Done", statuses: ["Closed", "Resolved", "Deployed", "Done"] },
    ],
  },
};
const SOURCES = Object.keys(BOARDS);
const JIRA_STATUSES = BOARDS.jira.columns.flatMap((c) => c.statuses);
// A status the board does not map lands in its first column rather than vanishing.
const jiraColumn = (i) => Math.max(0, BOARDS.jira.columns.findIndex((c) => c.statuses.includes(i.status)));
BOARDS.jira.columns.forEach((c, n) => (c.test = (i) => jiraColumn(i) === n));

// 7×7 pixel icon for the header, drawn as divs like the sessions picker's.
const BOARD_ICON = ["#######", "#.#.#.#", "#.#.#.#", "#.#...#", "#...#.#", "#.....#", "#######"];
function pixelIcon(rows, color) {
  return v_flex().flex_none().children(rows.map((row) => h_flex().children([...row].map((ch) => div().w(2).h(2).when(ch === "#", (el) => el.bg(color))))));
}

const age = (iso) => {
  if (!iso) return "";
  const m = Math.max(0, (Date.now() - Date.parse(iso)) / 60000);
  if (m < 60) return `${Math.round(m)}m`;
  if (m < 1440) return `${Math.round(m / 60)}h`;
  return `${Math.round(m / 1440)}d`;
};

// Through a login fish: Herdr started from the Dock lacks the PATH that finds gh and acli.
async function script(...args) {
  const r = await exec("fish", ["-l", "-c", "exec $argv", SCRIPT, ...args]);
  if (r.code !== 0) throw new Error(r.stderr.trim().split("\n")[0] || `issues.sh exited ${r.code}`);
  return r.stdout;
}

function load(key) {
  try {
    return JSON.parse(localStorage.getItem(key) ?? "null");
  } catch {
    return null;
  }
}

export default class Issues extends View {
  init(_props, cx) {
    const cached = load(CACHE);
    const view = load(VIEW);
    this.items = cached?.items ?? [];
    this.updated = cached?.updated ?? null;
    this.errors = [];
    this.source = SOURCES.includes(view?.source) ? view.source : "github";
    this.repo = null; // GitHub chip: a repository name
    this.person = view?.person ?? "@me"; // Jira chip: null (everyone), "@me", "@none" or a name
    this.filter = "";
    this.picker = null; // {item, states, at}
    this.who = null; // {at} while the assignee list is open
    this.drag = null; // {item, from, over} while a Jira card is held
    this.note = "";
    this.loading = false;
    this.reset();

    this.h = cx.focus_handle();
    this.input = InputState.new({ placeholder: "Filter by title, key, person, label, repo" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value().toLowerCase();
      this.reset();
      cx.notify();
    });
    // While the filter has the keyboard, letters type instead of running board keys.
    this.typing = false;
    this.input.on("focus", () => (this.typing = true));
    this.input.on("blur", () => (this.typing = false));
    this.whoInput = InputState.new({ placeholder: "Search people" });
    this.whoInput.on("change", (_e, cx) => {
      if (this.who) this.who.at = 0;
      cx.notify();
    });
    this.whoInput.on("submit", (_e, cx) => {
      this.pickPerson(this.people()[this.who?.at ?? 0]);
      cx.notify();
    });
    this.input.on("submit", (_e, cx) => {
      this.h.focus();
      cx.notify();
    });
    this.h.focus();
    cx.timer.after(600, () => this.h.focus());
    this.refresh(cx);
  }

  board() {
    return BOARDS[this.source];
  }

  reset() {
    const n = this.board().columns.length;
    this.col = 0;
    this.row = Array(n).fill(0);
    this.top = Array(n).fill(0);
  }

  save() {
    localStorage.setItem(VIEW, JSON.stringify({ source: this.source, person: this.person }));
  }

  close() {
    closeOverlay(props().overlay);
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const data = JSON.parse(await script("list"));
        this.items = data.items;
        this.errors = data.errors;
        this.updated = Date.now();
        localStorage.setItem(CACHE, JSON.stringify({ items: this.items, updated: this.updated }));
      } catch (e) {
        this.errors = [{ source: "board", message: String(e.message ?? e) }];
      }
      this.loading = false;
      cx.notify();
    });
  }

  // This board's items after the text filter; chips count from here so they stay in sync.
  sourced() {
    const f = this.filter;
    return this.items.filter(
      (i) =>
        i.source === this.source &&
        (!f || [i.title, i.key, i.group, i.author, i.assignee, i.status, ...i.labels].some((v) => v?.toLowerCase().includes(f))),
    );
  }

  chipped(i) {
    if (this.source === "github") return !this.repo || i.group === this.repo;
    if (this.person === "@me") return i.mine;
    if (this.person === "@none") return !i.assignee;
    return !this.person || i.assignee === this.person;
  }

  columns() {
    const shown = this.sourced().filter((i) => this.chipped(i));
    return this.board().columns.map((c) => shown.filter(c.test));
  }

  selected() {
    return this.columns()[this.col][this.row[this.col]];
  }

  move(dcol, drow) {
    const cols = this.columns();
    this.col = Math.max(0, Math.min(cols.length - 1, this.col + dcol));
    const n = cols[this.col].length;
    this.row[this.col] = Math.max(0, Math.min(n - 1, this.row[this.col] + drow));
    // shortcut: drop cards above the window instead of scrolling to the selection; plain
    // lists have no scroll-to-item. Upgrade if a scroll handle for div lists appears.
    const r = this.row[this.col];
    this.top[this.col] = Math.max(0, Math.min(this.top[this.col], r, n - 1), r - SHOWN + 1);
  }

  setSource(id) {
    this.source = id;
    this.repo = null;
    this.reset();
    this.save();
  }

  // Run an action, then reload so the card lands where it now belongs.
  act(cx, label, ...args) {
    this.note = `${label}…`;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        await script(...args);
        this.note = "";
        this.refresh(cx);
      } catch (e) {
        this.note = `${label} failed: ${e.message}`;
      }
      cx.notify();
    });
  }

  assign(cx) {
    const i = this.selected();
    if (i && !i.mine) this.act(cx, `Assigning ${i.key}`, "assign", i.source, i.id);
  }

  // The card moves at once; a status Jira refuses puts it back. No reload: the sprint takes
  // ~20 s to fetch and nothing else about the card changed.
  setStatus(cx, item, status) {
    if (item.status === status) return;
    const was = item.status;
    item.status = status;
    this.note = `${item.key} → ${status}…`;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        await script("move", "jira", item.id, status);
        this.note = "";
        localStorage.setItem(CACHE, JSON.stringify({ items: this.items, updated: this.updated }));
      } catch (e) {
        item.status = was;
        this.note = `${item.key} → ${status} failed: ${e.message}`;
      }
      cx.notify();
    });
  }

  shiftCard(cx, step) {
    const i = this.selected();
    if (!i || i.source !== "jira") return;
    const to = BOARDS.jira.columns[jiraColumn(i) + step];
    if (to) this.setStatus(cx, i, to.to);
  }

  openStates() {
    const item = this.selected();
    if (item?.source === "jira") this.picker = { item, states: JIRA_STATUSES, at: Math.max(0, JIRA_STATUSES.indexOf(item.status)) };
  }

  // Assignee choices for the Jira board, narrowed by the search box; `id` is a `this.person`.
  people() {
    const sourced = this.sourced();
    const counts = new Map();
    for (const i of sourced) if (i.assignee && !i.mine) counts.set(i.assignee, (counts.get(i.assignee) ?? 0) + 1);
    const q = this.whoInput.value().toLowerCase();
    return [
      { id: null, label: "Everyone", n: sourced.length },
      { id: "@me", label: "Me", n: sourced.filter((i) => i.mine).length },
      { id: "@none", label: "Unassigned", n: sourced.filter((i) => !i.assignee).length },
      ...[...counts].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])).map(([p, n]) => ({ id: p, label: p, n })),
    ].filter((o) => !q || o.label.toLowerCase().includes(q));
  }

  openWho() {
    this.whoInput.set_value("");
    this.who = { at: 0 };
    this.whoInput.focus();
  }

  pickPerson(o) {
    this.who = null;
    this.h.focus();
    if (!o) return;
    this.person = o.id;
    this.reset();
    this.save();
  }

  startAgent() {
    const i = this.selected();
    if (!i) return;
    this.close();
    run("tab.new", { name: i.key, argv: ["claude"], task: `${i.key}: ${i.title}\n${i.url}` });
  }

  onKey(e, cx) {
    const k = e.key;
    const shift = e.modifiers?.shift;
    if (this.typing) {
      if (k !== "escape") return;
      this.h.focus();
      cx.stop_propagation();
      return cx.notify();
    }
    if (this.who) {
      const n = this.people().length;
      if (k === "escape") this.pickPerson(null);
      else if (k === "down") this.who.at = Math.min(this.who.at + 1, n - 1);
      else if (k === "up") this.who.at = Math.max(this.who.at - 1, 0);
      else return; // letters and Enter belong to the search box
      cx.stop_propagation();
      return cx.notify();
    }
    if (this.picker) {
      const p = this.picker;
      if (k === "escape") this.picker = null;
      else if (k === "down" || k === "j") p.at = Math.min(p.at + 1, p.states.length - 1);
      else if (k === "up" || k === "k") p.at = Math.max(p.at - 1, 0);
      else if (k === "enter") {
        this.picker = null;
        this.setStatus(cx, p.item, p.states[p.at]);
      } else return;
    } else if (k === "escape") return this.close();
    else if (shift && k === "h") this.shiftCard(cx, -1);
    else if (shift && k === "l") this.shiftCard(cx, 1);
    else if (k === "left" || k === "h") this.move(-1, 0);
    else if (k === "right" || k === "l") this.move(1, 0);
    else if (k === "down" || k === "j") this.move(0, 1);
    else if (k === "up" || k === "k") this.move(0, -1);
    else if (k === "enter" || k === "o") {
      const i = this.selected();
      if (i) cx.open_url(i.url);
    } else if (k === "a") this.assign(cx);
    else if (k === "s") this.openStates();
    else if (k === "p" && this.source === "jira") this.openWho();
    else if (k === "c") return this.startAgent();
    else if (k === "r") this.refresh(cx);
    else if (k === "/") this.input.focus();
    else if (k === "1" || k === "2") this.setSource(SOURCES[Number(k) - 1]);
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  render() {
    const t = theme();
    const board = this.board();
    const cols = this.columns();
    cols.forEach((items, c) => {
      this.row[c] = Math.max(0, Math.min(this.row[c], items.length - 1));
      this.top[c] = Math.min(this.top[c], this.row[c]);
    });
    const sourced = this.sourced();
    const jira = this.source === "jira";
    const sprint = this.items.find((i) => i.sprint)?.sprint;

    const chip = (id, label, n, on, onClick) =>
      h_flex().id(id).h(24).px(8).gap(6).items_center().rounded(6).cursor_pointer()
        .when(on, (el) => el.bg(t.selected)).hover((s) => s.bg(on ? t.selected : t.hover))
        .on_click((_e, cx) => { onClick(); cx.notify(); })
        .role("button").aria_selected(on)
        .child(div().text_color(on ? t.ansi2 : t.muted).when(on, (d) => d.font_bold()).child(label))
        .child(div().text_color(t.dim).child(String(n)));

    const chips = () => {
      if (!jira) {
        const repos = [...new Set(sourced.map((i) => i.group))].sort();
        const pick = (g) => () => { this.repo = g; this.reset(); };
        return [chip("repo-all", "All repos", sourced.length, !this.repo, pick(null)),
          ...repos.map((g) => chip(`repo-${g}`, g, sourced.filter((i) => i.group === g).length, this.repo === g, pick(g)))];
      }
      const current = this.people().find((o) => o.id === this.person) ?? { label: this.person, n: 0 };
      return [h_flex().id("who").h(24).px(8).gap(6).items_center().rounded(6).cursor_pointer()
        .when(Boolean(this.who), (el) => el.bg(t.selected)).hover((s) => s.bg(t.hover)).role("button")
        .on_click((_e, cx) => { if (this.who) this.pickPerson(null); else this.openWho(); cx.notify(); })
        .child(div().text_color(t.dim).child("Assignee"))
        .child(div().text_color(t.foreground).child(this.person === "@me" ? "Me" : this.person === "@none" ? "Unassigned" : this.person ?? "Everyone"))
        .child(div().text_color(t.dim).child("\u25be"))];
    };

    const card = (i, c, r) => {
      const on = c === this.col && r === this.row[c];
      const held = this.drag?.item === i;
      return v_flex()
        .id(`card-${i.source}-${i.id}`).w_full().flex_none().mb(6).py(8).px(10).gap(4).rounded(6).border_1().cursor_pointer()
        .border_color(on ? t.ansi2 : "#00000000").bg(on ? t.selected : t.background).hover((s) => s.bg(on ? t.selected : t.hover))
        .when(held, (el) => el.opacity(0.5))
        .role("list_item").aria_selected(on)
        .on_mouse_down("left", (_e, cx) => {
          this.col = c;
          this.row[c] = r;
          if (jira) this.drag = { item: i, from: c, over: c };
          cx.notify();
        })
        .child(h_flex().gap(6).items_center().text_size(11)
          .child(div().text_color(t.ansi2).font_bold().child(i.key))
          .child(div().flex_1().min_w(0).truncate().text_color(t.dim).child(jira ? i.kind : i.group))
          .when(i.status === "draft", (el) => el.child(div().text_color(t.dim).child("draft"))))
        .child(div().text_color(on ? t.foreground : t.muted).child(i.title))
        .when(jira || i.labels.length > 0, (el) => el.child(h_flex().gap(4).overflow_hidden().text_size(11)
          .when(jira, (el) => el.child(div().flex_none().px(6).rounded(9).bg(t.raised).text_color(t.foreground).child(i.status)))
          .children(i.labels.slice(0, 3).map((l) => div().flex_none().px(6).rounded(9).border_1().border_color(t.border).text_color(t.muted).child(l)))))
        .child(h_flex().text_size(11).text_color(t.dim)
          .child(div().flex_1().min_w(0).truncate().child(jira ? i.assignee ?? "Unassigned" : i.author ?? ""))
          .child(div().child(age(i.updated))));
    };

    const column = (col, c) => {
      const items = cols[c];
      const on = c === this.col;
      const target = this.drag && this.drag.over === c && this.drag.from !== c;
      return v_flex().id(`col-${c}`).flex_1().min_w(0).h_full().min_h(0).p(8).gap(8).rounded(8).border_1()
        .border_color(target ? t.accent : "#00000000").bg(target ? t.selected : t.chrome)
        .on_mouse_move((_e, cx) => {
          if (this.drag && this.drag.over !== c) {
            this.drag.over = c;
            cx.notify();
          }
        })
        .on_mouse_up("left", (_e, cx) => {
          const d = this.drag;
          this.drag = null;
          if (d && d.from !== c) this.setStatus(cx, d.item, col.to);
          cx.notify();
        })
        .child(h_flex().px(4).gap(8).items_center().font_family(PIXEL).text_size(14)
          .child(div().flex_1().min_w(0).truncate().text_color(on ? t.foreground : t.muted).child(col.label.toUpperCase()))
          .child(div().text_color(items.length ? t.ansi2 : t.dim).child(String(items.length))))
        .child(items.length
          ? v_flex().id(`issues-col-${c}`).flex_1().min_h(0).overflow_y_scrollbar()
              .children(items.slice(this.top[c]).map((i, k) => card(i, c, this.top[c] + k)))
          : div().py(6).text_color(t.dim).child(this.loading && !this.items.length ? "Loading…" : "Nothing here"));
    };

    const key = (k, what) =>
      h_flex().gap(4).items_center()
        .child(div().px(4).border_1().border_color(t.border).bg(t.raised).text_color(t.muted).child(k))
        .child(div().text_color(t.dim).child(what));

    const picker = this.picker && v_flex().absolute().top(120).left(480).w(320).p(8).gap(2).rounded(8).border_1().border_color(t.accent).bg(t.popover)
      .child(div().px(6).pb(4).text_color(t.muted).child(`Move ${this.picker.item.key} to`))
      .children(this.picker.states.map((s, k) =>
        h_flex().id(`state-${s}`).h(26).px(8).items_center().rounded(4).cursor_pointer()
          .when(k === this.picker.at, (el) => el.bg(t.selected)).hover((st) => st.bg(t.hover))
          .text_color(s === this.picker.item.status ? t.dim : t.foreground)
          .on_click((_e, cx) => { const p = this.picker; this.picker = null; this.setStatus(cx, p.item, s); cx.notify(); })
          .child(s)));

    const options = this.who ? this.people() : [];
    const whoPanel = this.who && v_flex().absolute().top(80).left(14).w(320).p(8).gap(6).rounded(8).border_1().border_color(t.accent).bg(t.popover)
      .child(h_flex().h(30).px(8).gap(6).items_center().border_1().border_color(t.input).rounded(6).bg(t.background)
        .child(Input.new(this.whoInput).flex_1().h_full().text_size(13).text_color(t.foreground)))
      .child(v_flex().id("who-list").max_h(380).overflow_y_scrollbar().role("list_box").children(options.map((o, k) =>
        h_flex().id(`who-${o.id ?? "all"}`).h(28).px(8).gap(8).items_center().rounded(4).cursor_pointer().flex_none()
          .role("list_box_option").aria_selected(o.id === this.person)
          .when(k === this.who.at, (el) => el.bg(t.selected).aria_active_descendant()).hover((st) => st.bg(t.hover))
          .on_click((_e, cx) => { this.pickPerson(o); cx.notify(); })
          .child(div().flex_1().min_w(0).truncate().text_color(o.id === this.person ? t.accent : t.foreground).child(o.label))
          .child(div().text_color(t.dim).child(String(o.n))))))
      .when(!options.length, (el) => el.child(div().px(8).py(4).text_color(t.dim).child("No one matches")));

    return v_flex()
      .id("issues").track_focus(this.h).w_full().h(760).min_h(0).relative().p(14).gap(10).bg(t.popover).text_size(13).font_family(MONO)
      .on_key_down((e, cx) => this.onKey(e, cx))
      .on_mouse_up("left", (_e, cx) => { if (this.drag) { this.drag = null; cx.notify(); } })
      .child(h_flex().gap(10).items_center()
        .child(h_flex().gap(8).items_center().font_family(PIXEL).text_size(15)
          .child(pixelIcon(BOARD_ICON, t.muted)).child(div().text_color(t.muted).child("ISSUES")))
        .child(div().w(1).h(16).bg(t.border))
        .children(SOURCES.map((s, k) => chip(`src-${s}`, `${k + 1} ${BOARDS[s].label}`, this.items.filter((i) => i.source === s).length, this.source === s, () => this.setSource(s))))
        .when(jira && Boolean(sprint), (el) => el.child(div().text_size(11).text_color(t.dim).child(sprint)))
        .child(h_flex().flex_1().h(30).px(10).gap(8).items_center().border_1().border_color(t.accent).bg(t.background)
          .child(div().text_color(t.accent).font_bold().child(">"))
          .child(Input.new(this.input).flex_1().h_full().text_size(13).text_color(t.foreground)))
        .child(div().text_size(11).text_color(t.dim).child(this.loading ? "Updating…" : this.updated ? `Updated ${age(new Date(this.updated).toISOString())} ago` : ""))
        .child(h_flex().id("refresh").px(8).h(24).items_center().rounded(6).cursor_pointer()
          .hover((s) => s.bg(t.hover)).role("button").on_click((_e, cx) => this.refresh(cx)).text_color(t.muted).child("r refresh")))
      .child(h_flex().gap(6).flex_wrap().children(chips()))
      .children(this.errors.map((e) => div().text_size(11).text_color(t.blocked).child(`${e.source}: ${e.message.split("\n")[0]}`)))
      .child(h_flex().flex_1().min_h(0).gap(8).items_start().children(board.columns.map((col, c) => column(col, c))))
      .when(Boolean(this.note), (el) => el.child(div().text_size(11).text_color(t.muted).child(this.note)))
      .child(h_flex().gap(14).pt(4).border_t(1).border_color(t.border).text_size(11)
        .child(key("h/j/k/l", "move"))
        .child(key("↵", "open"))
        .child(key("a", "assign me"))
        .when(jira, (el) => el
          .child(key("drag · H/L", "move card"))
          .child(key("s", "status"))
          .child(key("p", "assignee")))
        .child(key("c", "claude"))
        .child(key("1-2", "board"))
        .child(key("/", "filter"))
        .child(key("esc", "close")))
      .when(Boolean(picker), (el) => el.child(picker))
      .when(Boolean(whoPanel), (el) => el.child(whoPanel));
  }
}
