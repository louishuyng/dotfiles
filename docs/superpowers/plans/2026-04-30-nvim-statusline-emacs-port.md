# Nvim Statusline — Doom Emacs Port — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Re-skin `nvim/lua/ui/statusline.lua` so the bar visually matches the user's Doom Emacs `doom-modeline`, while preserving nvim-only segments (marlin, snipai, macro-recording, gitsigns diff stats).

**Architecture:** Single-file refactor. New segment functions are added top-to-bottom in the same file, using the existing `color()` helper and `setup_highlights()` pattern. The final `M.statusline()` is reordered to the new layout. Two old functions (`line_tracking`, `file_encoding`) and one highlight (`StlEncoding`) are removed. Catppuccin remains the palette source.

**Tech Stack:** Neovim 0.12, Lua, catppuccin.nvim (palette), nvim-web-devicons (filetype/file icons), gitsigns (branch + diff stats), built-in `vim.lsp` and `vim.diagnostic`.

**Testing approach:** This file has no existing test harness, and statusline rendering is a UI concern best verified by eye. Each task ends with a manual verification step (open nvim, observe segment) followed by a commit. No unit tests are added.

**Spec:** `docs/superpowers/specs/2026-04-30-nvim-statusline-emacs-port-design.md`

---

## File Structure

Single file modified: `nvim/lua/ui/statusline.lua`.

| Section | Change |
|---|---|
| Top: `setup_highlights()` | Add 5 new highlight groups, remove `StlEncoding` |
| Module-scope `mode_colors` table | Hoist from inside `mode_color()` so `mode_letter()` can share it |
| Existing `mode_color()` (rename → `mode_bar()`) | Renamed; logic unchanged; uses hoisted table |
| New: `mode_letter()` | Returns `Ⓝ Ⓘ Ⓥ Ⓡ Ⓒ` colored by mode |
| New: `file_size()` | Returns `2.2k` / `1.5M` / `nil` |
| New: `position()` | Returns `46:11 All` (replaces `line_tracking()`) |
| New: `lsp_rocket()` | Returns `󱓞` when an LSP is attached |
| New: `filetype()` | Returns `<icon> TypeScript`-style filetype display |
| New: `git_branch()` | Returns ` <branch>` from gitsigns |
| Removed: `line_tracking()`, `file_encoding()` | Deleted |
| `M.statusline()` | Section list reordered to spec |

---

## Task 1: Add new highlight groups, remove `StlEncoding`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua:14-25` (the `setup_highlights()` body)

- [ ] **Step 1: Edit `setup_highlights()`**

In `nvim/lua/ui/statusline.lua`, replace the highlight block (lines 14-25) with:

```lua
  local hl = vim.api.nvim_set_hl
  hl(0, 'StlModeNormal', { fg = c.green, bold = true })
  hl(0, 'StlModeInsert', { fg = c.mauve, bold = true })
  hl(0, 'StlModeVisual', { fg = c.yellow, bold = true })
  hl(0, 'StlModeCommand', { fg = c.peach, bold = true })
  hl(0, 'StlModeReplace', { fg = c.red, bold = true })
  hl(0, 'StlModified', { fg = c.peach, bold = true })
  hl(0, 'StlReadOnly', { fg = c.red, bold = true })
  hl(0, 'StlInfo', { fg = c.blue })
  hl(0, 'StlAccent', { fg = c.teal })
  hl(0, 'StlSnipai', { fg = c.mauve, bold = true })
  hl(0, 'StlFileSize', { fg = c.overlay1 })
  hl(0, 'StlBranch', { fg = c.mauve, bold = true })
  hl(0, 'StlFiletype', { fg = c.yellow })
  hl(0, 'StlRocket', { fg = c.green })
  hl(0, 'StlScroll', { fg = c.subtext0 })
```

Note: `StlEncoding` is gone; the new `StlFileSize`, `StlBranch`, `StlFiletype`, `StlRocket`, `StlScroll` are added.

- [ ] **Step 2: Reload nvim and verify no errors**

Run in nvim: `:source %` while editing the file, then `:messages`. Expected: no error output. The bar still renders the old layout (we haven't changed `M.statusline()` yet); only the highlight setup changed.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "refactor(nvim/statusline): add highlight groups for new segments"
```

---

## Task 2: Hoist `mode_colors` to module scope and rename `mode_color` → `mode_bar`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua:146-166` (the `mode_color` function)

This prepares the table for sharing between `mode_bar()` (the `▎` glyph) and `mode_letter()` (added next).

- [ ] **Step 1: Lift table out and rename function**

Replace the existing `mode_color` definition (currently lines 146-166) with:

```lua
local MODE_COLORS = {
  n = 'StlModeNormal',
  i = 'StlModeInsert',
  v = 'StlModeVisual',
  V = 'StlModeVisual',
  [''] = 'StlModeInsert', -- ctrl-i fallback (kept from prior impl)
  c = 'StlModeCommand',
  s = 'StlModeVisual',
  S = 'StlModeVisual',
  [''] = 'StlModeVisual', -- ctrl-v block visual
  R = 'StlModeReplace',
  Rv = 'StlModeReplace',
  t = 'StlModeInsert',
}

local function mode_bar()
  local mode = vim.api.nvim_get_mode().mode
  local color_group = MODE_COLORS[mode] or 'StlInfo'
  return color(color_group, '▎')
end
```

- [ ] **Step 2: Update the call site in `M.statusline()`**

In `M.statusline()` (currently line 234), change the first entry from `mode_color(),` to `mode_bar(),`:

```lua
  local sections = {
    mode_bar(),
    file_name(),
    ...
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %` then switch modes (`i`, `Esc`, `v`, `Esc`, `:`). Expected: the `▎` bar at the far left changes color exactly as before — green in normal, mauve in insert, yellow in visual, peach in command, red in replace.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "refactor(nvim/statusline): hoist MODE_COLORS, rename mode_color -> mode_bar"
```

---

## Task 3: Add `mode_letter()`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — add new function below `mode_bar()`

- [ ] **Step 1: Add the function**

Right after the `mode_bar()` definition added in Task 2, append:

```lua
local MODE_LETTERS = {
  n = 'Ⓝ',
  i = 'Ⓘ',
  v = 'Ⓥ',
  V = 'Ⓥ',
  [''] = 'Ⓥ',
  c = 'Ⓒ',
  s = 'Ⓢ',
  S = 'Ⓢ',
  [''] = 'Ⓢ',
  R = 'Ⓡ',
  Rv = 'Ⓡ',
  t = 'Ⓣ',
}

local function mode_letter()
  local mode = vim.api.nvim_get_mode().mode
  local color_group = MODE_COLORS[mode] or 'StlInfo'
  local letter = MODE_LETTERS[mode] or 'Ⓝ'
  return color(color_group, letter)
end
```

- [ ] **Step 2: Wire into `M.statusline()`**

Insert `mode_letter(),` between `mode_bar()` and `file_name()`:

```lua
  local sections = {
    mode_bar(),
    mode_letter(),
    file_name(),
    ...
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %`. Expected: a colored circled letter (`Ⓝ` in green) appears just right of the `▎` bar. Switch modes — letter changes to `Ⓘ` (mauve), `Ⓥ` (yellow), `Ⓒ` (peach), `Ⓡ` (red).

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): add colored mode letter badge"
```

---

## Task 4: Add `file_size()`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — add new function above `M.statusline()`

- [ ] **Step 1: Add the function**

Add this function in the section helpers (e.g. just before `function M.statusline()`):

```lua
local function file_size()
  local fname = vim.api.nvim_buf_get_name(get_current_bufnr())
  if fname == '' then
    return nil
  end
  local stat = vim.uv.fs_stat(fname)
  if not stat then
    return nil
  end
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
end
```

- [ ] **Step 2: Wire into `M.statusline()`**

Insert `file_size(),` between `mode_letter()` and `file_name()`:

```lua
  local sections = {
    mode_bar(),
    mode_letter(),
    file_size(),
    file_name(),
    ...
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %`. Open this very file (`:e nvim/lua/ui/statusline.lua`). Expected: a dim grey/overlay-colored size like `2.5k` appears between the mode letter and the filename. Open `:enew` (scratch buffer): file size segment is hidden (no file on disk).

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): add file size segment"
```

---

## Task 5: Replace `line_tracking()` with `position()`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — remove `line_tracking()` (currently lines 194-209), add `position()`

- [ ] **Step 1: Delete `line_tracking()`**

Remove the entire `line_tracking` function (currently lines 194-209):

```lua
local function line_tracking()
  ...
end
```

- [ ] **Step 2: Add `position()`**

In its place, add:

```lua
local function position()
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
end
```

The `%%%%` is intentional: `string.format` consumes one `%` per `%%`, producing `%%` in the result; the statusline then renders `%%` as a literal `%`.

- [ ] **Step 3: Wire into `M.statusline()`**

The right cluster currently has `' '`, `line_tracking()`, `' '`, `file_encoding()`. Position now goes on the **left**, just before `%=`. Update `M.statusline()` to (we'll do the full reorder in Task 9, but for now just swap `line_tracking()` for `position()` so the bar still renders):

In `M.statusline()` change:

```lua
    -- Right side
    '%=',
    ' ',
    line_tracking(),
    ' ',
    file_encoding(),
```

to:

```lua
    -- Right side
    '%=',
    ' ',
    position(),
    ' ',
    file_encoding(),
```

(We will move `position()` to the left cluster and drop `file_encoding()` in Task 9.)

- [ ] **Step 4: Verify**

Run in nvim: `:source %`. Expected: where the old `Top`/`Bot`/`46/100` was, you now see `46:11 All` (or `Top` / `Bot` / `xx%`). Move the cursor (`gg`, `G`, scroll), confirm `Top` / `Bot` / percent transitions work. Confirm `%` renders as a single `%`, not `%%`.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): replace line_tracking with line:col + scroll-word position"
```

---

## Task 6: Add `lsp_rocket()`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — add new function

- [ ] **Step 1: Add the function**

Add near the other right-side helpers (e.g. just before `function M.statusline()`):

```lua
local function lsp_rocket()
  local bufnr = get_current_bufnr()
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    return nil
  end
  return color('StlRocket', '󱓞')
end
```

- [ ] **Step 2: Wire into `M.statusline()`**

Insert `lsp_rocket(),` immediately after `'%='` (i.e. as the first thing in the right cluster):

```lua
    -- Right side
    '%=',
    lsp_rocket(),
    ' ',
    position(),
    ' ',
    file_encoding(),
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %`. Open a TypeScript file in a project with LSP configured. Expected: a green rocket `󱓞` appears just after `%=` once LSP attaches (may take a beat). Run `:LspStop` — rocket disappears. Run `:edit` to reattach — rocket returns.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): show rocket when LSP attached"
```

---

## Task 7: Add `filetype()` with display-name map

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — add new function

- [ ] **Step 1: Add the function**

Add near the other helpers:

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
  scss            = 'SCSS',
  sh              = 'Shell',
  zsh             = 'Zsh',
  fish            = 'Fish',
}

local function filetype()
  local ft = vim.bo[get_current_bufnr()].filetype
  if ft == '' then
    return nil
  end
  local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(ft)
  local name = FT_DISPLAY[ft] or (ft:sub(1, 1):upper() .. ft:sub(2))
  local icon_str = icon and color(hl or 'StlFiletype', icon) or ''
  if icon_str ~= '' then
    return icon_str .. ' ' .. color('StlFiletype', name)
  end
  return color('StlFiletype', name)
end
```

- [ ] **Step 2: Wire into `M.statusline()`**

Insert `filetype(),` after `lsp_rocket()`:

```lua
    -- Right side
    '%=',
    lsp_rocket(),
    filetype(),
    ' ',
    position(),
    ' ',
    file_encoding(),
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %`. Open a TS file: expect `󰛦 TypeScript` (or whatever the devicon is) in yellow. Open a Lua file: expect `󰢱 Lua`. Open `:enew` scratch (no filetype): segment hidden.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): add filetype segment with display-name map"
```

---

## Task 8: Add `git_branch()`

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — add new function

- [ ] **Step 1: Add the function**

Add near the other helpers:

```lua
local function git_branch()
  local bufnr = get_current_bufnr()
  local head = vim.b[bufnr].gitsigns_head or vim.g.gitsigns_head
  if not head or head == '' then
    return nil
  end
  return color('StlBranch', ' ' .. head)
end
```

`vim.b.gitsigns_head` is per-buffer (set when gitsigns attaches to a tracked file). `vim.g.gitsigns_head` is the cwd's HEAD; it's the fallback so the branch still renders for untracked files inside a repo.

- [ ] **Step 2: Wire into `M.statusline()`**

Insert `git_branch(),` after `filetype()` and before `git_changes()` (which is currently mid-list — we'll move it next to branch in Task 9). For now just append it temporarily:

```lua
    -- Right side
    '%=',
    lsp_rocket(),
    filetype(),
    git_branch(),
    ' ',
    position(),
    ' ',
    file_encoding(),
```

- [ ] **Step 3: Verify**

Run in nvim: `:source %`. Open this file inside the dotfiles repo. Expected: ` main` (or whatever the current branch is) appears in mauve, just after the filetype. `cd` into a non-git directory and `:edit foo` — branch hidden.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "feat(nvim/statusline): add git branch segment"
```

---

## Task 9: Final reorder of `M.statusline()` and remove dead code

**Files:**
- Modify: `nvim/lua/ui/statusline.lua` — `M.statusline()` body and remove `file_encoding()`

- [ ] **Step 1: Delete `file_encoding()`**

Remove the entire `file_encoding` function (currently around lines 211-218):

```lua
local function file_encoding()
  ...
end
```

- [ ] **Step 2: Replace `M.statusline()` body**

Replace the `sections` table inside `M.statusline()` with the final layout:

```lua
function M.statusline()
  local sections = {
    -- Left cluster
    mode_bar(),
    mode_letter(),
    file_size(),
    file_name(),
    file_modified(),
    file_read_only(),
    marlin_index(),
    snipai_status(),
    macro_recording(),
    position(),
    -- Separator
    '%=',
    -- Right cluster
    lsp_rocket(),
    filetype(),
    git_branch(),
    git_changes(),
    lsp_status(),
  }

  return table.concat(
    vim.tbl_filter(function(section)
      return section
    end, sections),
    ' '
  )
end
```

Notes on the changes vs. the prior intermediate state:
- `position()` moved from the right cluster (where it was placed temporarily in Task 5) to the end of the left cluster, matching the spec.
- `git_changes()` moved from the middle (where it was originally) to the right cluster, immediately after `git_branch()`, so `+12 ~3 -1` sits next to ` main`.
- `file_encoding()` removed.
- The stray `''` filler that used to follow `file_read_only()` (line 238 in the original) is removed — `vim.tbl_filter` plus the `' '` join handles spacing.

- [ ] **Step 3: Verify the full layout**

Run in nvim: `:source %`. Open `nvim/lua/ui/statusline.lua` itself in a TS-adjacent buffer (or any file with LSP attached) inside the dotfiles repo. Expected layout, left to right:

```
▎ Ⓝ  2.5k  󰢱 statusline.lua  +(maybe)  46:11 All     %=    󱓞  Lua   main +A ~M -D  diagnostics
```

Specifically check:
- Mode bar `▎` and mode letter `Ⓝ` are colored together (same color)
- File size sits between them and the filename
- Modified `+` only shows when the buffer is dirty
- Position sits at the end of the left cluster, before the `%=` gap
- Right cluster order: rocket → filetype → branch → diff stats → diagnostics
- No `utf-8` indicator anywhere

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/statusline.lua
git commit -m "refactor(nvim/statusline): final layout reorder, drop file_encoding"
```

---

## Task 10: Manual end-to-end verification

**Files:** none (verification only)

This task confirms the spec's testing plan items end-to-end. No code changes.

- [ ] **Step 1: TypeScript file with LSP**

Open a TS file in a project that has typescript-language-server configured. Confirm: rocket visible (LSP attached), filetype shows `TypeScript`, branch renders.

- [ ] **Step 2: Scratch buffer**

Run `:enew`. Confirm: file size hidden, branch hidden (no buffer file → fallback may still show cwd branch if gitsigns_head is set globally; that's expected and acceptable), filetype hidden (no filetype set), rocket hidden (no LSP).

- [ ] **Step 3: Mode toggling**

Cycle through `n` (Esc), `i` (insert), `v` (visual), `V` (visual line), `Ctrl-v` (visual block), `:` (command), `R` (replace). Confirm: bar AND letter both change color simultaneously each time. Letter shape changes for n→i→v→c→R.

- [ ] **Step 4: Macro recording**

Press `qq` to start recording macro to register `q`. Confirm: `@q` appears mid-left in red. Press `q` again to stop. Confirm: `@q` disappears.

- [ ] **Step 5: Diff stats**

Edit a tracked file, add a few lines, modify one, delete one. Save. Wait for gitsigns to refresh. Confirm: `+a ~m -d` appears on the right immediately after ` main`.

- [ ] **Step 6: Diagnostics**

In a TS file, introduce a deliberate type error (e.g. `const x: number = "string"`). Confirm: error count appears at the far right, after diff stats.

- [ ] **Step 7: Filetype change**

Use `:e foo.lua` then `:e bar.ts`. Confirm: filetype name and devicon update each time.

- [ ] **Step 8: LSP detach/reattach**

Run `:LspStop`. Confirm: rocket disappears. Reopen the buffer (`:e`). Confirm: rocket returns once the server reattaches.

- [ ] **Step 9: Scroll word**

In a file longer than the window, hit `gg` (Top), `G` (Bot), and a middle position (xx%). Confirm: scroll word transitions correctly. Open a short file that fits entirely on screen — confirm: `All`.

- [ ] **Step 10: Final visual sanity check against the screenshot**

Side-by-side compare the rendered nvim bar against the original Doom Emacs screenshot in the spec. The rhythm should match: colored bar/letter + size + path on the left, rocket + ft + branch + diagnostics on the right.

---

## Self-Review

Spec coverage check (each spec section → task):

| Spec section | Covered by |
|---|---|
| Layout (left + right cluster order) | Task 9 |
| `mode_bar()` (kept) | Task 2 (rename) |
| `mode_letter()` | Task 3 |
| `file_size()` | Task 4 |
| `position()` (replaces `line_tracking`) | Task 5 |
| `lsp_rocket()` | Task 6 |
| `filetype()` with display map | Task 7 |
| `git_branch()` with `vim.b`/`vim.g` fallback | Task 8 |
| `git_changes()` repositioned next to branch | Task 9 |
| Highlight groups added | Task 1 |
| `StlEncoding` removed | Task 1 |
| `line_tracking()` removed | Task 5 |
| `file_encoding()` removed | Task 9 |
| Manual verification matrix | Task 10 |

No spec gaps. No placeholders or "implement later" steps. Function names match between tasks (`mode_bar`, `mode_letter`, `file_size`, `position`, `lsp_rocket`, `filetype`, `git_branch` used consistently). Highlight group names match between Task 1 setup and the consumer functions (Tasks 3–8).
