---
name: architect-report
description: Build an interactive architecture report, one self-contained dark HTML page in the Vercel (Geist) report style that combines Diagram Design diagrams with report prose and a case switcher, so a reader can step through scenarios (happy path, failure, edge case) on the same colour-coded diagrams and compare two of them. Use when the user asks for an architecture report, a design or system walkthrough with diagrams, a "check these cases" page, or names architect-report. For one standalone diagram with no report, follow Diagram Design alone.
---

# Architect report

One HTML file. A reader opens it, gets the argument from the first screen, and
switches cases to see which parts of each diagram a scenario touches.

Four sources, each with one job:

| Source | Owns |
| --- | --- |
| `references/design.md` | How the page is composed and worded: Vercel's report judgement, the component list, the reject list, the review order |
| `references/skin.md` | Every value: Geist dark greys, the colour of each case and node kind, type roles, spacing |
| Diagram Design, vendored at `~/.dotfiles/ai/vendor/diagram-design/skills/diagram-design` (source and commit in `vendor.json`) | Geometry inside an `<svg>`: type choice, layout, connectors, budgets. Not colours. |
| `assets/report.html` | The working page: stylesheet, the case runtime, print rules, a complete example report |
| `assets/components.html` | Every component with its markup, on the same stylesheet: notes, badges, stats, entity rows, endpoints, bars, request trace, gauge, progress, matrix, steps, timeline, code block, snippet, file tree, controls |

When the network allows, also read <https://vercel.com/design.md>. It is
Vercel's own skill for report pages and the authority behind `design.md`.
The report is the user's, never Vercel's: no Vercel wordmark, triangle or name.

## Steps

1. **Frame the reader's job.** Answer the four questions at the top of
   `references/design.md`. Collect the system, the reader and the cases. A case
   is one scenario a reader wants to trace: a happy path, a failure, an edge
   case, a before and after. Two to five cases. If the user gave none, propose
   them and say so. Never invent a component, a number or a decision; an
   unknown goes under open questions.
2. **Plan the diagrams.** Read the vendored `SKILL.md` §3 and pick a type per
   diagram. Start with one context diagram, then one per view that needs it
   (sequence, state, data). Each stays inside the Diagram Design budget of
   9 nodes and 12 arrows. Past the budget, add a diagram.
3. **Assign colours** from `references/skin.md`: one colour per case and one
   per node kind, the same in every diagram of the report.
4. **State the plan** in one short message: the claim the title will make, the
   cases with their colours, each diagram with its type, and what the budget
   forces out. Continue unless the user redirects.
5. **Load the references.** This skill's `references/design.md` and
   `references/skin.md`; then, under the vendor root,
   `references/primitives-core.md`, `references/layout-budget.md` and each
   `references/type-<type>.md`. Take colours and fonts only from `skin.md`.
   Skip the first-run style gate in the vendored `SKILL.md` §0, and ignore the
   hex values, the one-accent limit and the serif title in vendored snippets
   and templates.
6. **Copy `assets/report.html`** to the user's project and replace its content.
   It is a working example, so open it first to see the contract in use. Keep
   the `<style data-architect-report>` and `<script data-architect-report>`
   blocks; the script is copied verbatim. Build the page only from the
   components listed in `design.md`, taking their markup from
   `assets/components.html`. Pick each one from the question it answers, using
   the table in `design.md`.
7. **Draw each diagram** by the Diagram Design rules in the `skin.md` colours,
   then tag it with the case contract below.
8. **Check, look, revise.** Run the check script and fix every finding. Then
   open the page in a browser and walk the review order in `design.md`. A
   passing script does not prove the page reads well.

## Case contract

The runtime reads these attributes. Nothing else is needed to add a case.

| Attribute | On | Meaning |
| --- | --- | --- |
| `data-case-pick="<id>"` | A button in the case bar | Declares a case. The button text is its name. Keep the first button, with an empty value, as "All cases". |
| `data-case="<id> <id>"` | A `<g>` inside a diagram | This group belongs to these cases. When another case is active it dims. |
| `data-case="<id>"` | Any element outside a diagram: a `.case-note`, a `<td>`, a trace row, a note | Shown only when its case is active or compared. |
| `data-detail="<element id>"` | A node `<g>` inside a diagram | Clicking the node opens the inspector with the content of the `<details>` that has this id. |
| `data-case-status` | Any element | Its text becomes the name of the active case, or both when comparing. |
| `data-filter="<selector>"` and `data-filter-empty="<selector>"` | A search `<input>` | Hides the matched items that lack the typed text and shows the empty message when none is left. |
| `data-copy="<selector>"` | A button | Copies the text of the selected element and confirms for a moment. |
| `data-needs-script` with `hidden` | Any element that only works with scripting | The runtime unhides it. Use it for the case bar, the filter field, and hints about clicking. |

Rules:

- **Untagged means shared.** A node or connector every case uses carries no
  `data-case` and never dims. Tag only what differs between cases.
- **Group a connector with its label.** Put the line, its label mask, and its
  label text in one tagged `<g>`, so they dim together.
- **A connector that belongs to one case is drawn in that case's colour**, with
  the matching arrow marker. One that belongs to several cases stays grey.
- **Key every case colour.** Put `<span class="dot" data-tone="…" aria-hidden="true">`
  before the case name in its button, its `.case-note` and its table column head.
- **Prefix every id with the diagram slug**, markers included: `ctx-arrow`,
  `ctx-arrow-red`, `ctx-title`. Two diagrams share one document, so a bare
  `arrow` collides.
- **Draw in place.** No `transform` on a tagged group; the geometry check reads
  raw coordinates.
- **Each diagram's `min-width` equals its viewBox width.** The template sets
  960px for the `doc-inline` preset. A wider preset needs its own rule.
- **Details stay reachable without the diagram.** Every `data-detail` target is
  a `<details>` in the page, so keyboard and screen-reader users open it
  directly. The inspector is a pointer shortcut that copies that content.
- **The case lives in the query string** (`?case=timeout&vs=happy`), so a link
  reopens the same view.

With scripting off, and in print, every case shows at full strength and every
note is visible. Write the report so it reads correctly in that state.

## Report sections

Keep the order; drop a section that has nothing true to say. Every heading
states a claim, as `design.md` describes.

1. Masthead: who wrote it, and at most two sourced facts.
2. Opening: the title as the conclusion, and one orienting passage.
3. Case bar.
4. One section per diagram: a sentence of context, the figure with a caption that says what to notice, one `.case-note` per case, and component details where a node needs more than its label.
5. Sections for other evidence the material has: a request trace, bars against a budget, a rollout in steps, an incident timeline, a risk matrix. Only what the reader's question needs.
6. The cases compared in a table, one column per case, tagged with `data-case`.
7. What is decided and what is open.

## Check

```sh
python3 <skill-dir>/scripts/check_report.py <report.html>
```

It checks the case contract and the runtime script, then runs Diagram Design's
`self_check.py` and `verify_geometry.py` on each diagram alone. Those two gates
reject any script and read a file as one canvas, which is why this wrapper
exists; do not run them on the report directly. They also reject any remote
link other than the Google Fonts stylesheet.

Then, in a browser: switch to every case, compare two, press Back, reload,
click two nodes in a row and press Escape, type in the filter until nothing
matches, tab through every control, and view the page at 320px wide. Take a
full-page screenshot and compare it with a screenshot of `assets/report.html`;
a block that looks unlike the template is a component used wrongly.

## Limits

- Dark only. The diagrams carry literal colours, so the page has no light theme, and print keeps the dark ground.
- Compare shows two cases stacked, not overlaid.
- Diagram Design's motion modes are not supported in a report; the case switcher replaces them.
- The inspector uses the Popover API. A browser without it opens the matching `<details>` instead.
- Charts with axes and curves (line, scatter, area) are not components here. Draw them as a Diagram Design chart type.
- Bars, trace rows and the matrix use CSS subgrid and `color-mix`, which need a browser from 2023 or later.
- Another look means new values in `references/skin.md`. Change the diagram colours and the `:root` tokens in the page together.

Output files go in the user's project, never in the skill or vendor folder.
