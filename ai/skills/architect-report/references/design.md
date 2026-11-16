# Design: how the report should look and read

The target is the judgement behind Vercel's own report pages, not their
decoration. Vercel publishes that judgement as a skill at
<https://vercel.com/design.md>. When the network allows, read it before
designing; it is the authority and this file is a working summary in our own
words, narrowed to architecture reports.

Three differences from that skill:

- **This report is not Vercel's.** Never use the Vercel wordmark, triangle or
  name as authorship. The masthead names the user's team or the report.
- **Dark only**, with our own stylesheet in `assets/report.html`. Do not link
  Vercel's `vercel-brand.css` or use `vbg-*` class names.
- **The diagrams use colour.** Vercel's report skill designs in monochrome. An
  architecture report has two things colour makes faster to read, the case a
  path belongs to and the kind of a node, so the diagrams use the full Geist
  palette under the rules in `skin.md`. The page chrome stays monochrome.

## Start from the reader

Before any layout, answer four questions:

1. Who opens this, and to decide or understand what?
2. What is the strongest answer the material supports?
3. Which diagram or comparison makes that answer credible?
4. Which limit or open question could change it?

The page then serves two reading speeds. Someone who reads only the title, the
headings, the captions and the last section gets the argument. Someone who
audits finds the exact table, the component details and the open questions.

## Compose the page

- **The first screen is the argument.** Title, one orienting passage, the case
  bar, and the top of the main diagram are visible at 1440 by 900. No cover, no
  summary cards, no metadata block before the evidence.
- **One continuous black canvas.** Separate things with space, alignment and
  type. A border or a surface must be earned by interaction, selection, a
  warning, or a grouping that space cannot express. In this template only the
  case bar, table rows, disclosure rows and the inspector have one.
- **No frame around a diagram.** The diagram paper is the page ground. It needs
  no card, no rounded rectangle and no header strip.
- **One focal thing per section.** The diagram, or the table. Everything else
  in the section supports it and is quieter.
- **Width follows content.** Prose stays inside the reading width. Diagrams and
  tables take all twelve columns. Do not strand a table in a narrow column or
  leave a large empty rectangle beside a short block.
- **Every gap has one owner.** A wrapper sets the space between its children;
  the children add no margins of their own. Close inside a group, clearly
  larger between sections.
- **End on the decision.** The last section says what is decided and what is
  open. The footer is one quiet line.

## Write the words

- **A heading states the claim**, in sentence case: "Every case diverges after
  the charge call", not "System context". The title says what the reader should
  conclude, not the genre of the document.
- **A caption states what to notice** and, when it matters, what the diagram
  does not show.
- **Plain words first.** Define an unfamiliar term once, then keep using that
  exact term. Keep exact names and units in tables and details.
- **Simplify the language, never the claim.** Keep every qualifier, condition
  and unit that changes the meaning.
- No eyebrow labels, no all-capital or tracked labels in the page, no
  decorative section numbers, no em dashes, no praise, and no sentence about
  how the page was organised.

## Components

Every component exists once in the stylesheet of `assets/report.html`.
`assets/components.html` shows each one with its markup; copy from there. Use a
component unchanged, and only for the question it answers.

The names and the rules for when to use each follow Vercel's Geist components
(<https://vercel.com/geist/introduction.md>; append `.md` to any component
page, for example <https://vercel.com/geist/note.md>).

### Pick the visual from the question

| The reader asks | Use |
| --- | --- |
| What talks to what? What depends on what? | A diagram (Diagram Design) |
| What happens in this scenario? | The case bar on a diagram |
| How do the scenarios differ, exactly? | The cases table |
| Where does the time go inside one request? | Trace |
| Which is biggest? Is it over the limit? | Bars, with a limit marker |
| How much of a fixed maximum is used? | Gauge |
| How far along is work with a known total? | Progress |
| In what order do stages run, and where are we? | Steps |
| What happened when? | Timeline |
| How likely and how bad is each failure? | Matrix |
| What are the facts about this one component? | Description, or an entity list for several |
| What is the API? | Endpoint rows |
| What does the code or the layout look like? | Code block, snippet, file tree |
| What must I not miss here? | Note |

If a table answers it as fast, use the table. If one sentence answers it, write
the sentence.

### Page and controls

| Need | Use | Rule |
| --- | --- | --- |
| Who and what | `header.masthead` | Left: the team or report name as text. Right: at most two sourced facts in `.meta`. |
| Orientation | `h1` and one `.lede` | One passage. No second summary further down. |
| Switch case | `.casebar` with `.segmented` of `button.button[aria-pressed]` | Pressed is the white one. Five buttons at most. |
| Pick one of many | `<span class="select"><select>` in a `<label class="field">` | Native select. Always labelled. |
| Type text | `<input class="input">` in a `<label class="field">` | Label above. The placeholder is an example ending in an ellipsis, never the label. |
| Act | `button.button` | A text label. An icon-only button needs `aria-label`. |
| Peers side by side | `.grid` with `.span-6` | Only for true peers with the same structure. |
| Floating detail | `aside.inspector[popover]` | The one surface with a shadow, because it floats. |

### Evidence

| Need | Use | Rule |
| --- | --- | --- |
| Diagram | `figure.diagram` | A `.meta` status line, the SVG in `.diagram-scroll`, a `figcaption`. |
| Per-case remark | `p.case-note[data-case]` | Starts with the case's `.dot` and its name in `strong`. Plain text, no box. |
| Lookup | `table` in `.table-wrap` | A `caption`, `th scope`, text left, numbers right with `.numeric` on head and cells. Body cells align to the first baseline. |
| Request trace | `ol.trace` | One row per span: `.trace-name` (indent with `--depth`), a `.trace-span` placed with `--start` and `--length` as percentages of the axis, `.trace-time`. End with a `.trace-axis` row. Say whether the timings are measured. |
| Ranked quantities | `ul.bars` | All rows share one scale. `--value` is a percentage of that scale; state the scale in the caption. `.bar-limit` marks a budget. |
| Ratio of a maximum | `span.gauge` | `--value` from 0 to 100, with the number as its text. Green, amber or red by a stated threshold. |
| Work with a total | `progress` | Real `value` and `max`, inside a `label` that says what is counted. |
| Likelihood and impact | `table.matrix` | Each cell holds its word and a tone. Never colour alone. |
| Ordered stages | `ol.steps` | Three to six. A tone on a stage states its status. |
| Events in time | `ol.timeline` | A `time` and one sentence per event. |

### Facts, status and code

| Need | Use | Rule |
| --- | --- | --- |
| Key and value pairs | `dl.description` | A short noun as the key, one value. |
| Sourced numbers | `.stat-strip` | Two to four true peers: label, value, detail. Never an invented metric, never boxed. |
| Rows of things | `ul.entity-list` | Name and one line on the left, one badge on the right. |
| API operation | `p.endpoint` | `.method` with its tone (GET green, POST blue, PUT and PATCH amber, DELETE red), the path in `code`, one sentence. |
| Attention | `p.note` | Next to the block it concerns. Plain for context, amber risk, red fault, green confirmed, blue pointer. Starts with its kind in `strong`. |
| State or category | `span.badge` | Next to the thing it describes, one per row. Not for ordinary metadata. |
| Colour key | `span.dot[data-tone]`, `ul.legend` | Before a case name, or in a legend. Never as a status light on its own. |
| Disclosure | `details` and `summary` | Native marker. Hairline above each row. |
| Points | `ul` | Short full sentences. |
| Source code | `figure.code` | A file name in the `figcaption`, one `span.line` per line. A tone marks a line: green added, red removed, blue referred to. |
| Command | `.snippet` | One command in `code`, and a copy button with `data-copy`. |
| Layout of files | `ul.tree` | `.dir` for folders. A tone marks the files the report is about. |
| Technical string | `code`, `kbd` | Mono for the identifier only, not its sentence. |

Every control has rest, hover, focus-visible, pressed or selected, and disabled
states. Hover and pressed raise contrast. A text field's edge is 3:1 on the
page; a button's label identifies it, so its edge may be a hairline.

Tones are set with `data-tone` (green, red, amber, blue, purple, teal, pink)
and keep the meanings in `skin.md`. A component without a tone is grey.

More components do not make a better report. Use the two or three that the
material earns; a page that shows every component is a catalogue, not an
argument.

## Reject on sight

- A card, panel or rounded rectangle around every section, metric or diagram.
- Cards inside cards, or a border added to repair weak hierarchy.
- Boxes of metrics when one composed relationship would be clearer.
- A badge or pill for ordinary metadata or labels.
- Gradients, glows, blobs, glass, textures, grid or dot backgrounds, ornamental shadows.
- A centred hero followed by a grid of cards.
- Icons as decoration, icons in tiles, emoji as icons.
- Tiny grey prose, arbitrary font sizes, peers set in different sizes.
- Colour because something is good or important, a hue with two meanings, or a colour with no key.
- A legend where a direct label fits.
- A visible theme switch, a section that repeats an earlier one, or sections that all share one silhouette.

Avoiding these is not the goal either. A page that is only black, thin rules
and wide margins is as generic as the cards were. The standard is precise
hierarchy, strong alignment, clear evidence and one deliberate focal point.

## Motion

Still by default. A colour change on a control takes 120ms. Nothing enters,
bounces, pulses or reveals on scroll. Everything works with motion off.

## Review before handing back

Render the page and check, in this order:

1. **First read.** From the first screen alone, would the reader remember the central claim?
2. **Language.** Could the least specialised reader repeat the answer from headings and captions?
3. **Composition.** One dominant object per section? Any accidental empty space?
4. **Type.** Only the roles in `skin.md`? Peers identical? Baselines aligned?
5. **Evidence.** Does the diagram prove the heading above it? Are tables full width, with headers aligned to their cells?
6. **Restraint.** Can a border, surface, label or section go without losing meaning? Then remove it. Does every hue have one meaning and a key?
7. **Reflow.** No sideways page scroll at 320px, and no word broken mid-character.
8. **Access.** Landmarks, one `h1`, ordered headings, skip link, visible focus, labels, text alternatives.

Squint at the page: the dominant claim and the reading path should be obvious.
If every block has the same weight, redesign before polishing.

Fix the largest systemic problem first, render again, and repeat. Deliver the
page, not a score or a critique.
