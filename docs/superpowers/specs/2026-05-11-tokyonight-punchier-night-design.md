# tokyonight — Punchier Night

Date: 2026-05-11
Scope: `nvim/lua/config/theme/adapters/tokyonight.lua`

## Goal

Make the tokyonight `night` (dark) variant feel richer and more electric without losing its blue-leaning nocturnal identity. Light variant (`day`) is left untouched.

## Mechanism

Inject overrides through tokyonight's `on_colors` callback inside `M.setup`. `tokyonight.colors.setup({style=...})` runs `on_colors` before returning the palette, so the same overrides flow into:

- the colorscheme highlights (when tokyonight applies its own highlight groups), and
- `M.resolve()`'s semantic palette (used by statusline, snacks, cmp, ...).

No post-processing inside `M.resolve()` is required. Overrides are gated on `style == 'night'` so the `day` palette stays as upstream.

## Color overrides (night only)

Backgrounds — deeper, near-OLED stage:

| key | old | new |
|---|---|---|
| `bg` | `#1a1b26` | `#0f1018` |
| `bg_dark` | `#16161e` | `#0a0b12` |
| `bg_highlight` | `#292e42` | `#252a44` |

Foreground — sharper contrast, less muddy comments:

| key | old | new |
|---|---|---|
| `fg` | `#c0caf5` | `#dbe3ff` |
| `comment` | `#565f89` | `#6c75a8` |

Accents — saturated/electric while staying in family:

| key | old | new |
|---|---|---|
| `blue` | `#7aa2f7` | `#82aaff` |
| `cyan` | `#7dcfff` | `#86e1fc` |
| `green` | `#9ece6a` | `#aef07a` |
| `magenta` | `#bb9af7` | `#c8a6ff` |
| `purple` | `#9d7cd8` | `#b48eff` |
| `red` | `#f7768e` | `#ff6e88` |
| `orange` | `#ff9e64` | `#ffae5b` |
| `yellow` | `#e0af68` | `#ffcb6b` |
| `teal` | `#1abc9c` | `#2ee0bd` |

## Non-goals

- No `on_highlights` overrides (no per-group recoloring).
- No changes to the `day` (light) palette.
- No changes to the semantic role mapping in `M.resolve()` — still:
  `primary=green, secondary=teal, tertiary=magenta`, etc.

## Verification

- `:Theme dark=tokyonight` then eyeball: a normal source file, Telescope, cmp menu, snacks dashboard, cursorline glow on a long buffer.
- Flip back to catppuccin (`:Theme dark=catppuccin`) and back to confirm the palette callbacks rebuild cleanly.
