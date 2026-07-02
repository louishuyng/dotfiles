# Nvim Theme Redesign — Neutral Forest

**Date:** 2026-04-04  
**Status:** Approved  

## Summary

Redesign the existing "Deep Forest" Neovim palette by removing green tint from backgrounds, upgrading to a richer blue/purple accent palette, and switching to pure neutral white foreground. The green identity is preserved in strings and key UI elements (borders, cursor line, Telescope). Implementation is a direct in-place edit of `nvim/lua/utils/highlights.lua` using the existing `mini.base16` setup — no new plugins, no structural changes.

---

## Palette Changes

### Backgrounds (base00–base02) — remove all green tint

| Key    | Old         | New         | Role                    |
|--------|-------------|-------------|-------------------------|
| base00 | `#111411`   | `#111111`   | Main background         |
| base01 | `#161a16`   | `#161616`   | Sidebar / panels        |
| base02 | `#1e2820`   | `#1e1e1e`   | Cursorline / selection  |

### Foreground (base03–base07) — neutral greys

| Key    | Old         | New         | Role                    |
|--------|-------------|-------------|-------------------------|
| base03 | `#4a6650`   | `#3d4040`   | Comments                |
| base04 | `#7a9e80`   | `#8a9099`   | Line numbers / dimmed   |
| base05 | `#d4edd0`   | `#e2e2e2`   | Body text (main fg)     |
| base06 | `#e2f5de`   | `#efefef`   | Light fg                |
| base07 | `#eefaeb`   | `#f5f5f5`   | Brightest fg            |

### Accents — richer hues, green stays for strings

| Key    | Old         | New         | Role                            |
|--------|-------------|-------------|---------------------------------|
| base08 | `#e06c75`   | `#f7768e`   | Errors / brackets               |
| base09 | `#d4956a`   | `#ff9e64`   | Booleans / constants            |
| base0A | `#d4b96a`   | `#e0af68`   | Numbers / warnings / search bg  |
| base0B | `#7dc97d`   | `#9ece6a`   | Strings ★ green identity        |
| base0C | `#72c4b8`   | `#7dc97d`   | Functions / UI green accents    |
| base0D | `#72aad4`   | `#7aa2f7`   | Keywords / directory names      |
| base0E | `#b07dd4`   | `#bb9af7`   | Types / classes                 |
| base0F | `#d48872`   | `#f7768e`   | Special / deprecated            |

---

## UI Highlight Overrides (no structural changes)

The `M.apply()` function in `highlights.lua` keeps all existing overrides. The palette variable update propagates automatically. Specific overrides that reference colors directly by hex (e.g. `nvim-notify` `background_colour`) must also be updated:

- `nvim-notify` `background_colour`: `#1e222a` → `#161616` (in `nvim/lua/plugins/ui.lua`)

All other overrides use `p.baseXX` references and require no changes beyond the palette table.

---

## Files to Change

1. **`nvim/lua/utils/highlights.lua`** — update `M.palette` table (12 values)
2. **`nvim/lua/plugins/ui.lua`** — update hardcoded `background_colour` in nvim-notify opts

---

## Out of Scope

- Lualine / bufferline styling (not flagged as a pain point)
- Adding a theme switcher or new palette files
- Changing the colorscheme plugin (`mini.base16` stays)
