# Nvim Statusline — Doom Emacs Port

**Date:** 2026-04-30
**Status:** Design
**File touched:** `nvim/lua/ui/statusline.lua`

## Goal

Re-skin the existing custom Neovim statusline to match the visual layout of the
user's Doom Emacs `doom-modeline`. The user works across both editors and wants
a consistent at-a-glance bar so context-switching is instant.

The Emacs reference (left → right):

```
▎ N  2.2k   alert/src/workflows/automated-content-creation/get-details/usecase.spec.ts  46:11 All     󱓞  TypeScript   main  ⊗ 0  △ 0  ⓘ 2
```

## Background

- Existing nvim statusline lives in a single file: `nvim/lua/ui/statusline.lua`.
- It is wired in via `vim.o.statusline = [[%!v:lua.require('ui.statusline').statusline()]]`.
- Highlight groups are derived from `catppuccin.palettes` and re-applied on
  `ColorScheme` autocmd. Catppuccin remains the active nvim theme.
- Existing segments to keep: mode bar, file name + devicon, modified `+`,
  read-only `‼`, marlin index, snipai status, macro recording, lsp diagnostics,
  gitsigns diff stats.
- Existing segments to remove: standalone `Top/Bot/lineno` line tracking,
  `file_encoding` (the `utf-8` indicator).
- Doom Emacs config is `doom! :ui modeline` (vanilla doom-modeline), no
  custom configuration. The screenshot is the default doom-modeline rendering
  on the catppuccin-macchiato theme.

## Scope decision: hybrid replica

The user picked a **hybrid** approach: match the doom-modeline visual rhythm,
but keep nvim-only segments (marlin, snipai, macro-recording, gitsigns diff
stats) tucked into the layout where they fit naturally. Marlin/snipai/macro
sit on the left near the filename (file-related state); gitsigns diff stats
sit on the right next to the branch name (git-related state).

## Final layout

```
▎ Ⓝ  2.2k  󰈙 alert/.../usecase.spec.ts  +  󰵺 1/3  [snipai]  @q  46:11 All       %=         TypeScript   main +12 ~3 -1  ⊗ 0  △ 0  ⓘ 2
```

**Left cluster (in order):**
1. `mode_bar()` — `▎`, colored by current mode (kept from existing impl)
2. `mode_letter()` — `Ⓝ Ⓘ Ⓥ Ⓡ Ⓒ` (Unicode circled letters), colored by mode (new)
3. `file_size()` — buffer byte size formatted as `123` / `2.2k` / `1.5M` (new)
4. `file_name()` — devicon + folder/file path (kept)
5. `file_modified()` — `+` if modified (kept)
6. `file_read_only()` — `‼` if readonly (kept)
7. `marlin_index()` — `󰵺 i/n` if buffer is in marlin list (kept)
8. `snipai_status()` — snipai statusline text (kept)
9. `macro_recording()` — `@q` while recording (kept)
10. `position()` — `46:11 All` (line:col + scroll word) (new, replaces `line_tracking()`)

**Separator:** `%=`

**Right cluster (in order):**
1. `lsp_rocket()` — `󱓞` (nf-md-rocket-launch, U+F14DE) when any LSP client is attached (new)
2. `filetype()` — devicon + filetype name, e.g. `󰛦 TypeScript` (new)
3. `git_branch()` — ` <branch>` from `vim.b.gitsigns_head` (new)
4. `git_changes()` — `+12 ~3 -1` from `vim.b.gitsigns_status_dict` (kept, moved here)
5. `lsp_status()` — diagnostic counts (kept)

## Component contracts

Each segment is a top-level function returning `string` or `nil`. `nil` causes
the segment to be filtered out of the final concatenation by the existing
`vim.tbl_filter` in `M.statusline()`.

| Function | Returns | Notes |
|---|---|---|
| `mode_bar()` | colored `▎` | Always present. |
| `mode_letter()` | colored `Ⓝ`/`Ⓘ`/`Ⓥ`/`Ⓡ`/`Ⓒ` | Always present. Falls back to `Ⓝ` for unknown modes. |
| `file_size()` | `2.2k` / `1.5M` / `nil` | `nil` if buffer has no on-disk file (unsaved/scratch). Read via `vim.uv.fs_stat()`. |
| `file_name()` | devicon + path | Existing impl, unchanged. |
| `file_modified()` | `+` / `nil` | Existing. |
| `file_read_only()` | `‼` / `nil` | Existing. |
| `marlin_index()` | `󰵺 i/n` / `nil` | Existing. |
| `snipai_status()` | snipai text / `nil` | Existing. |
| `macro_recording()` | `@<reg>` / `nil` | Existing. |
| `position()` | `46:11 All` | `All` if file fits, `Top` if line==1, `Bot` if line==last, else `xx%`. |
| `lsp_rocket()` | `󱓞` / `nil` | `nil` if `#vim.lsp.get_clients({bufnr=...}) == 0`. |
| `filetype()` | `<icon> <name>` / `nil` | `nil` if `vim.bo.filetype == ''`. Name is title-cased; uses devicon by filetype. |
| `git_branch()` | ` <name>` / `nil` | `nil` if `vim.b.gitsigns_head` is unset. |
| `git_changes()` | `+a ~m -d` / `nil` | Existing. |
| `lsp_status()` | diagnostic counts / `''` | Existing. |

## Highlight groups

`setup_highlights()` reads from `require('catppuccin.palettes').get_palette()`
and is re-applied on `ColorScheme`. The existing `pcall` guards remain.

**Kept:** `StlModeNormal`, `StlModeInsert`, `StlModeVisual`, `StlModeCommand`,
`StlModeReplace`, `StlModified`, `StlReadOnly`, `StlInfo`, `StlAccent`,
`StlSnipai`.

**Added:**
| Group | Source color | Used by |
|---|---|---|
| `StlFileSize` | `c.overlay1` | `file_size()` |
| `StlBranch` | `c.mauve` | `git_branch()` |
| `StlFiletype` | `c.yellow` | `filetype()` name (icon uses devicon's own hl) |
| `StlRocket` | `c.green` | `lsp_rocket()` |
| `StlScroll` | `c.subtext0` | `position()` scroll word |

**Removed:** `StlEncoding` (no longer used).

## Behavior details

### `position()`

```lua
local line  = vim.fn.line('.')
local col   = vim.fn.virtcol('.')
local total = vim.fn.line('$')
local first = vim.fn.line('w0')
local last  = vim.fn.line('w$')

local scroll
if first == 1 and last == total then
  scroll = 'All'
elseif line == 1 then
  scroll = 'Top'
elseif line == total then
  scroll = 'Bot'
else
  scroll = string.format('%d%%%%', math.floor((line - 1) / math.max(total - 1, 1) * 100))
end

return string.format(
  '%s:%s %s',
  color('StlInfo', tostring(line)),
  color('StlInfo', tostring(col)),
  color('StlScroll', scroll)
)
```

The `%%%%` is intentional: statusline format strings interpret `%`, so we
double-escape to render a literal `%` in the rendered bar.

### `file_size()`

```lua
local fname = vim.api.nvim_buf_get_name(get_current_bufnr())
if fname == '' then return nil end
local stat = vim.uv.fs_stat(fname)
if not stat then return nil end
local bytes = stat.size
local s
if bytes < 1024 then
  s = string.format('%dB', bytes)
elseif bytes < 1024 * 1024 then
  s = string.format('%.1fk', bytes / 1024)
else
  s = string.format('%.1fM', bytes / 1024 / 1024)
end
return color('StlFileSize', s)
```

### `lsp_rocket()`

```lua
local bufnr = get_current_bufnr()
if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then return nil end
return color('StlRocket', '󱓞')
```

### `filetype()`

```lua
local FT_DISPLAY = {
  typescript      = 'TypeScript',
  typescriptreact = 'TypeScript',
  javascript      = 'JavaScript',
  javascriptreact = 'JavaScript',
  json            = 'JSON',
  yaml            = 'YAML',
  html            = 'HTML',
  css             = 'CSS',
  -- fallback: capitalize first letter
}

local ft = vim.bo[get_current_bufnr()].filetype
if ft == '' then return nil end
local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(ft)
local name = FT_DISPLAY[ft] or (ft:sub(1, 1):upper() .. ft:sub(2))
local icon_str = icon and color(hl or 'StlFiletype', icon) or ''
return (icon_str ~= '' and (icon_str .. ' ') or '') .. color('StlFiletype', name)
```

### `git_branch()`

```lua
local head = vim.b[get_current_bufnr()].gitsigns_head or vim.g.gitsigns_head
if not head or head == '' then return nil end
return color('StlBranch', ' ' .. head)
```

`vim.b.gitsigns_head` is per-buffer (set when gitsigns attaches to a tracked
file). `vim.g.gitsigns_head` is the cwd's HEAD, used as a fallback so the
branch still renders when viewing untracked files inside a repo.

### `mode_letter()`

```lua
local letters = {
  n = 'Ⓝ', i = 'Ⓘ', v = 'Ⓥ', V = 'Ⓥ', [''] = 'Ⓥ',
  c = 'Ⓒ', s = 'Ⓢ', S = 'Ⓢ', [''] = 'Ⓢ',
  R = 'Ⓡ', Rv = 'Ⓡ', t = 'Ⓣ',
}
local mode = vim.api.nvim_get_mode().mode
return color(mode_colors[mode] or 'StlInfo', letters[mode] or 'Ⓝ')
```

`mode_colors` is the same table currently used by the mode bar — it can be
hoisted to module scope and shared between `mode_bar()` and `mode_letter()`.

## Removed code

- `line_tracking()` — replaced by `position()`
- `file_encoding()` — dropped per spec
- The `' '`, `line_tracking()`, `' '`, `file_encoding()` tail in `M.statusline()`

## Edge cases

- **Unsaved/scratch buffers** — `file_size`, `git_branch`, `filetype` (when
  empty) all return `nil` and are filtered out.
- **No LSP attached** — `lsp_rocket()` returns `nil`, the rocket disappears.
- **Non-git directory** — `gitsigns_head` is unset, branch hidden.
- **Theme not loaded yet** — `pcall` around the palette require already
  protects all highlight setup. New groups follow the same pattern.
- **Devicon for unknown filetype** — `get_icon_by_filetype` returns `nil`,
  fallback is just the name with no icon.
- **`vim.uv` vs `vim.loop`** — Neovim 0.10+ exposes `vim.uv` as the canonical
  alias. The repo is on 0.12, so `vim.uv` is safe.

## Testing plan

After implementation, manual verification:

1. Open a TS file in a git repo with LSP attached → all left + right segments visible, layout matches the reference screenshot.
2. Open `:enew` scratch buffer → file size, branch, filetype hidden cleanly.
3. Toggle modes `n` / `i` / `v` / `V` / `R` / `:` → mode bar AND mode letter both change color simultaneously.
4. Record macro with `qq` → `@q` appears mid-left; press `q` again → it disappears.
5. Edit a tracked file to introduce additions, modifications, deletions → diff stats `+a ~m -d` render to the right of `main`.
6. Trigger a diagnostic (introduce a TS type error) → counts increment after the branch.
7. Switch buffer to a Lua file → filetype updates from `Typescript` to `Lua`, devicon updates.
8. Detach LSP (`:LspStop`) → rocket disappears; reattach → rocket returns.
9. Long file (>screen): scroll word should cycle `Top` → `xx%` → `Bot` and show `All` only when whole file fits.

No automated tests; the file has no test harness today and the change is
purely UI rendering. Verification is by eye against the reference.

## Out of scope

- Theme switching to Tokyo Night (user confirmed catppuccin stays).
- Tabline changes.
- Inactive-window statusline (a separate `M.statusline_inactive` would be a
  follow-up; doom-modeline dims inactive windows but that's not in this spec).
- Performance optimization (caching). The functions are already cheap enough
  for redraw.
