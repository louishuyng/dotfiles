# cmp Kind Icons — Emacs / Codicon Refresh

**Date:** 2026-04-30
**Status:** Design
**Files affected:** `nvim/lua/config/libs/icons.lua`, `nvim/lua/config/cores/cmp.lua`

## Goal

Replace the heterogeneous nerd-font glyphs currently used for completion-kind icons with a single, consistent codicon (`nf-cod-symbol_*`) vocabulary so the cmp menu reads like an Emacs `lsp-mode` / `company-mode` popup — small geometric symbols rather than rounded Material Design glyphs.

Reference target: bracketed/boxed codicon shapes (cube for `Variable`, three-bar for `Keyword`, hexagon for `Namespace`, clover for `Class`, etc.).

## Non-goals

- No change to cmp formatting layout (kind / abbr / menu order, half-window truncation, etc.).
- No change to AI-completion brand icons (`Codeium`, `Copilot`, `TabNine`, `Supermaven`).
- No change to highlight groups (`CmpItemKind*`); colors remain whatever the colorscheme already provides.
- No change to other glyph tables (`diagnostics`, `git`, `debug`, `misc`).

## Design

### 1. Icon mapping (icons.lua → `kinds` table)

Every standard LSP kind maps to its codicon equivalent. Where codicons collapse multiple LSP kinds into one glyph (e.g. Function/Method/Constructor all share `symbol_method`), accept the visual duplication — that is the canonical codicon behavior and matches the Emacs aesthetic.

| Kind | Codicon name |
|---|---|
| Array | `nf-cod-symbol_array` |
| Boolean | `nf-cod-symbol_boolean` |
| Class | `nf-cod-symbol_class` |
| Color | `nf-cod-symbol_color` |
| Constant | `nf-cod-symbol_constant` |
| Constructor | `nf-cod-symbol_method` |
| Enum | `nf-cod-symbol_enum` |
| EnumMember | `nf-cod-symbol_enum_member` |
| Event | `nf-cod-symbol_event` |
| Field | `nf-cod-symbol_field` |
| File | `nf-cod-symbol_file` |
| Folder | `nf-cod-folder` |
| Function | `nf-cod-symbol_method` |
| Interface | `nf-cod-symbol_interface` |
| Key | `nf-cod-symbol_key` |
| Keyword | `nf-cod-symbol_keyword` |
| Method | `nf-cod-symbol_method` |
| Module | `nf-cod-symbol_namespace` |
| Namespace | `nf-cod-symbol_namespace` |
| Null | `nf-cod-symbol_null` |
| Number | `nf-cod-symbol_numeric` |
| Object | `nf-cod-symbol_namespace` |
| Operator | `nf-cod-symbol_operator` |
| Package | `nf-cod-package` |
| Property | `nf-cod-symbol_property` |
| Reference | `nf-cod-symbol_reference` |
| Snippet | `nf-cod-symbol_snippet` |
| String | `nf-cod-symbol_string` |
| Struct | `nf-cod-symbol_structure` |
| Text | `nf-cod-symbol_string` |
| TypeParameter | `nf-cod-symbol_parameter` |
| Unit | `nf-cod-symbol_ruler` |
| Value | `nf-cod-symbol_enum` |
| Variable | `nf-cod-symbol_variable` |

### 2. Non-LSP kinds — preserved or remapped

| Kind | Treatment |
|---|---|
| Codeium | unchanged (brand glyph) |
| Copilot | unchanged (brand glyph) |
| TabNine | unchanged (brand glyph) |
| Supermaven | unchanged (brand glyph) |
| Control | `nf-cod-symbol_misc` |
| Collapsed | `nf-cod-chevron_right` |

### 3. Format invariant — trailing space preserved

Every value in `icons.kinds` keeps a single trailing space, matching the existing convention. This keeps `cmp.lua`'s formatter `(' %s '):format(icons[kind])` rendering identically (one space on each side of the glyph).

### 4. Safety net — fallback for unknown kinds

`cmp.lua` line 62 currently does:

```lua
item.kind = (' %s '):format(icons[kind])
```

Note: `icons` at this point is the local from line 58, `require('config.libs.icons').kinds` — so `icons[kind]` looks up inside the `kinds` table.

If an LSP server returns a kind we haven't mapped, `icons[kind]` is `nil` and the popup renders `' nil '`. Add a fallback:

```lua
local kind_icon = icons[kind] or icons.Default
item.kind = (' %s '):format(kind_icon)
```

A new entry `kinds.Default` (codicon `symbol_misc`) is added to `icons.lua` so the fallback has a single source of truth and lives in the same table as the other kind glyphs.

### 5. Completeness verification

After editing `icons.lua`, confirm via inspection that:

- Every key currently present in `icons.kinds` is still present.
- No value in `icons.kinds` is `nil` or an empty string.
- `icons.kinds.Default` exists and is non-empty.

The simplest check: load the file in Neovim, `:lua print(vim.inspect(require('config.libs.icons').kinds))`, scan for empties.

## Risk

- **Glyph rendering** — all listed codicons are part of the standard Nerd Fonts codicon block; the user is already running a Nerd Font (current `icons.lua` uses `nf-md-*` and `nf-cod-*` glyphs that render fine). Risk: low.
- **Visual collision** between Function/Method/Constructor — accepted intentionally per design choice 3a.
- **Unknown LSP kinds** — mitigated by the `misc_fallback`.

## Out of scope (deferred)

- Bracket-wrapping each icon (`[ ]` literal characters).
- Per-kind highlight tinting (colored cell behind the glyph).
- Differentiating Function vs Method via separate glyphs.
