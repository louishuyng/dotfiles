# Skin: Geist dark

The only skin of this skill. It replaces the colour tables in Diagram Design's
`references/style-guide.md`; that file's stroke, radius, spacing and label
rules still apply. Resolve every `{role}` placeholder in a Diagram Design
snippet against this file.

## Sources

Read on 2026-11-17. Re-read them when a value looks wrong; do not correct one
from memory.

- Colour steps and their meaning: <https://vercel.com/geist/colors.md>
- Type roles: <https://vercel.com/geist/typography.md>
- Radii of surfaces: <https://vercel.com/geist/materials.md>
- Report tokens (spacing, widths, weights, control height, borders):
  <https://vercel.com/geist/vercel-brand.css>, the `--vbg-*` custom properties
- Hex values: the computed `--ds-*` properties of <https://vercel.com/geist/colors>
  in its dark theme. These are the sRGB fallbacks; Vercel serves wider P3
  values to displays that support them.

## Grey scale

Geist assigns each step one job. Keep the job when you pick a step.

| Step | Value | Job |
| --- | --- | --- |
| background | `#000000` | Page ground and diagram paper |
| surface | `#0a0a0a` | A floating surface (the inspector) |
| gray-100 | `#1a1a1a` | Component fill; hover fill on the ground |
| gray-200 | `#1f1f1f` | Pressed fill |
| gray-400 | `#2e2e2e` | Default border, when a solid one is needed |
| gray-600 | `#878787` | Node outline |
| gray-700 | `#8f8f8f` | Connector and boundary labels |
| gray-900 | `#a1a1a1` | Secondary text, connectors, sublabels |
| gray-1000 | `#ededed` | Primary text, the selected node's outline |

Hairlines use white at an alpha so they blend with what is under them:
`0.13` subtle, `0.14` default, `0.54` strong. Draw each border once; two alpha
borders that overlap show a brighter seam.

## Colour carries the cases and the kinds

The page chrome is black, white and grey. Colour lives in the diagrams and in
the small keys that point at them. Each hue has one meaning in the whole
report, and every coloured thing also has a cue that is not colour: a name, a
tag, a dash pattern or a label. Values are Geist's step 900, the step meant for
text and icons on a dark ground.

| Hue | Value | RGB for tints | Meaning |
| --- | --- | --- | --- |
| green | `#62c073` | `98,192,115` | The success case and a goal state |
| red | `#ff6166` | `255,97,102` | A failure case and a failure state |
| amber | `#f2a20d` | `242,162,13` | A degraded, waiting or retry case and state |
| blue | `#52a8ff` | `82,168,255` | The focal service; also the focus ring |
| purple | `#bf7af0` | `191,122,240` | An external system |
| teal | `#0ac7b4` | `10,199,180` | A data store |
| pink | `#f75f8f` | `247,95,143` | An async or optional component |

A coloured node has the hue as its stroke and the hue at `0.12` alpha as its
fill, over the opaque `paper` mask.

Rules:

- **Cases take green, red and amber first.** A fourth and fifth case take blue
  and purple, and then those two are not node kinds in that report.
- **A connector used by exactly one case takes that case's colour**; one used
  by several stays `muted`. Its label stays `soft`.
- **Node kinds take the rest.** Our own ordinary services stay grey, so the
  coloured kinds stand out.
- **Same meaning everywhere.** A hue never changes meaning between two
  diagrams of one report.
- **Key it.** Node kinds go in the diagram legend. Case colours go on the dot
  before each case name in the case bar, the notes and the table head.
- **Do not colour for emphasis.** Something important is the focal node, not a
  new hue.

## Diagram roles

| Role | Value |
| --- | --- |
| `paper` | `#000000` |
| `ink` | `#ededed` |
| `muted` | `#a1a1a1` |
| `soft` | `#8f8f8f` |
| `rule` | `rgba(237,237,237,0.10)` |
| `accent` | blue `#52a8ff`, with a 1.5 stroke as the second cue |
| `accent-tint` | `rgba(82,168,255,0.12)` |
| `link` | `#a1a1a1`; an external call is marked by its label and the purple node it reaches |

## Node treatments

| Type | Fill | Stroke |
| --- | --- | --- |
| `focal` (one or two) | blue at 0.12 | blue, width 1.5 |
| `backend`, a neutral state | `#1a1a1a` | `#878787` |
| `store` | teal at 0.12 | teal |
| `external` | purple at 0.12 | purple |
| `input` (a person or client) | `#000000` | `#666666` |
| `optional`, async | pink at 0.12 | pink, dashed `4,3` |
| goal state | green at 0.12 | green |
| failure state | red at 0.12 | red |
| waiting state | amber at 0.12 | amber |

A node's type tag uses its stroke colour: at 0.50 for the outline and full
strength for the text. Every node starts with an opaque `paper` mask rect.
Outlines are at least 3:1 on `paper`.

## Fonts

Geist for names and all page text. Geist Mono only for sublabels, tags,
connector labels, code, paths and identifiers. No serif anywhere; Diagram
Design's Instrument Serif roles are not used.

Load the variable faces, because headings use weight 450:
`family=Geist:wght@400..600&family=Geist+Mono:wght@400..600`.

## Type roles

| Role | Element | Size / line | Tracking | Weight |
| --- | --- | --- | --- | --- |
| Page title | `h1` | 40 / 48, 32 on narrow screens | -0.06em | 450 |
| Section | `h2` | 24 / 32 | -0.04em | 450 |
| Subsection | `h3` | 20 / 26 | -0.02em | 450 |
| Group | `h4` | 16 / 24 | -0.02em | 450 |
| Lede | `.lede` | 18 / 28 | 0 | 400, secondary colour |
| Body | `p`, `li` | 16 / 24 | 0 | 400 |
| Compact | tables, captions, controls | 14 / 20 | 0 | 400 |
| Metadata | `.meta`, field labels, table heads | 13 / 18 | 0 | 400, secondary colour |
| Emphasis | `strong` | inherits | 0 | 500 |

Use only these. Never set a font size or weight outside the table, and never
resize one peer because its text is longer.

## Space, shape, width

| Token | Value |
| --- | --- |
| Spacing | 4, 8, 12, 16, 20, 24, 32, 40, 48, 64px |
| Inside a group | 8 to 16px |
| Between groups | 24 to 32px |
| Between sections | 64px |
| Radius | 6px controls, 8px blocks, 12px floating surfaces |
| Content width | 1200px, 12 columns, 24px gutter |
| Reading width | 68ch |
| Control height | 36px, 44px on touch |
