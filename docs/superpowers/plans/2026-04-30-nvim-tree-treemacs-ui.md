# Replace neo-tree with nvim-tree (Treemacs UI) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Swap `nvim-neo-tree/neo-tree.nvim` for `nvim-tree/nvim-tree.lua`, configured to visually match Emacs Treemacs (root chevron, connected indent guides, git fringe, doom-themed colors), preserving the existing Snacks rename hook and `copy_selector` custom command.

**Architecture:** One plugin manifest edit (`pack.lua`), one full file rewrite (`nvim/lua/config/cores/tree.lua` — same require site so `init.lua` is untouched), and one new highlight module (`nvim/lua/ui/treemacs_highlights.lua`) loaded by `tree.lua` and re-applied on `ColorScheme`. There is no Lua test harness in this repo, so each task verifies via `nvim --headless` smoke commands and/or a final manual checklist run.

**Tech Stack:** Neovim 0.12 (`vim.pack`), Lua, `nvim-tree.lua`, `nvim-window-picker`, `nvim-web-devicons`, Tokyo Night colorscheme, Snacks (`Snacks.rename`, `Snacks.lazygit`).

**Spec:** `docs/superpowers/specs/2026-04-30-nvim-tree-treemacs-ui-design.md`

---

## File Structure

| Path | Action | Responsibility |
|---|---|---|
| `nvim/lua/config/pack.lua` | Modify | Plugin manifest: drop neo-tree, add nvim-tree.lua + nvim-window-picker |
| `nvim/lua/config/cores/tree.lua` | Rewrite | nvim-tree setup: behaviors, on_attach keymaps, custom `copy_selector`, Snacks rename subscriptions |
| `nvim/lua/ui/treemacs_highlights.lua` | Create | Highlight + sign definitions for Treemacs visual feel; idempotent, re-applied on `ColorScheme` |

`init.lua`, leader maps, sesh, tmux, statusline, and Snacks setup are not modified.

---

### Task 1: Swap plugin manifest

**Files:**
- Modify: `nvim/lua/config/pack.lua:72` (replace `neo-tree.nvim` line; add `nvim-tree.lua` and `nvim-window-picker` in the same Navigation block)

- [ ] **Step 1: Replace the neo-tree entry and add nvim-window-picker**

In `nvim/lua/config/pack.lua`, change line 72 from:

```lua
  'https://github.com/nvim-neo-tree/neo-tree.nvim',
```

to:

```lua
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/s1n7ax/nvim-window-picker',
```

Leave `MunifTanjim/nui.nvim` (line 7) in place — Neogit depends on it.

- [ ] **Step 2: Verify the manifest is still valid Lua**

Run: `nvim --headless -c "luafile nvim/lua/config/pack.lua" -c "qa"`
Expected: clean exit (no errors). Note: `vim.pack.add` will try to fetch the new plugins; that's fine the first time, may print download progress.

- [ ] **Step 3: Confirm new plugins are present and neo-tree is gone**

Run: `grep -nE "neo-tree|nvim-tree\.lua|nvim-window-picker" nvim/lua/config/pack.lua`
Expected: two lines, one for `nvim-tree/nvim-tree.lua` and one for `s1n7ax/nvim-window-picker`. No `nvim-neo-tree/neo-tree.nvim` line.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/pack.lua
git commit -m "chore(nvim/pack): swap neo-tree for nvim-tree + window-picker"
```

---

### Task 2: Skeleton nvim-tree config

Replace the neo-tree setup with a minimal nvim-tree setup that opens, closes, and sets the file as the require site for later tasks. We grow this in subsequent tasks.

**Files:**
- Rewrite: `nvim/lua/config/cores/tree.lua`

- [ ] **Step 1: Replace `tree.lua` with a minimal nvim-tree skeleton**

Overwrite `nvim/lua/config/cores/tree.lua` with:

```lua
-- nvim-tree, configured to feel like Emacs Treemacs.
-- Visual highlights live in nvim/lua/ui/treemacs_highlights.lua.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local ok, nvim_tree = pcall(require, 'nvim-tree')
if not ok then
  return
end

nvim_tree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  view = {
    width = 36,
    side = 'left',
    signcolumn = 'yes',
    number = false,
    relativenumber = false,
  },
})
```

- [ ] **Step 2: Smoke-check that the file loads and `:NvimTreeToggle` exists**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua print(vim.fn.exists(':NvimTreeToggle'))" -c "qa" 2>&1
```
Expected: prints `2` (the command exists). If it prints `0`, nvim-tree did not load — confirm Task 1's `vim.pack.add` actually fetched the plugin (open Neovim once to let `vim.pack` install it, then re-run).

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): skeleton nvim-tree setup replacing neo-tree"
```

---

### Task 3: Visual config — root chevron, icons, indent markers, filters

Layer the Treemacs-style renderer config onto the skeleton.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (the `nvim_tree.setup({...})` call)

- [ ] **Step 1: Extend the `setup` table with renderer + filter config**

Replace the `nvim_tree.setup({ ... })` call in `tree.lua` with:

```lua
nvim_tree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  view = {
    width = 36,
    side = 'left',
    signcolumn = 'yes',
    number = false,
    relativenumber = false,
  },
  renderer = {
    add_trailing = false,
    group_empty = false,
    highlight_git = true,
    highlight_opened_files = 'name',
    highlight_modified = 'name',
    root_folder_label = function(path)
      return '▾ ' .. vim.fn.fnamemodify(path, ':t')
    end,
    indent_width = 2,
    indent_markers = {
      enable = true,
      inline_arrows = true,
      icons = {
        corner = '╰',
        edge = '│',
        item = '├',
        bottom = '─',
        none = ' ',
      },
    },
    icons = {
      web_devicons = {
        file = { enable = true, color = true },
        folder = { enable = false, color = true },
      },
      git_placement = 'signcolumn',
      modified_placement = 'after',
      padding = ' ',
      symlink_arrow = ' ➜ ',
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        modified = true,
      },
      glyphs = {
        default = '',
        symlink = '',
        bookmark = '󰆤',
        modified = '●',
        folder = {
          arrow_closed = '',
          arrow_open = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
      },
    },
  },
  filters = {
    dotfiles = true,
    git_ignored = true,
    custom = {},
    exclude = {},
  },
})
```

- [ ] **Step 2: Smoke-check the file still loads**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua require('nvim-tree.api').tree.open()" \
  -c "lua print('ok')" -c "qa" 2>&1
```
Expected: prints `ok` with no Lua errors.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): treemacs-style renderer (root chevron, indent markers, icons)"
```

---

### Task 4: Behaviors — filewatch, follow current file, exclude open-replace

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (the `setup` table)

- [ ] **Step 1: Add `filesystem_watchers`, `update_focused_file`, and `actions.open_file`**

Inside the same `nvim_tree.setup({...})` call, add these top-level keys (place them after `filters`):

```lua
  filesystem_watchers = {
    enable = true,
    debounce_delay = 50,
    ignore_dirs = { 'node_modules', '.git/objects' },
  },
  update_focused_file = {
    enable = true,
    update_root = false,
    ignore_list = {},
  },
  actions = {
    change_dir = { enable = true, global = false, restrict_above_cwd = false },
    open_file = {
      quit_on_open = false,
      eject = true,
      resize_window = false,
      window_picker = {
        enable = true,
        picker = 'default',
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        exclude = {
          filetype = { 'notify', 'qf', 'trouble', 'terminal' },
          buftype = { 'terminal', 'quickfix' },
        },
      },
    },
  },
```

- [ ] **Step 2: Smoke-check load + open**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua require('nvim-tree.api').tree.open()" \
  -c "lua print('ok')" -c "qa" 2>&1
```
Expected: `ok`, no errors.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): filewatch, follow-current-file, open-replace excludes"
```

---

### Task 5: Git status integration in `setup`

Tell nvim-tree to render git, with a 100ms timeout and showing untracked files.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (the `setup` table)

- [ ] **Step 1: Add the `git` block to setup**

Inside `nvim_tree.setup({...})`, after `actions`, add:

```lua
  git = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
    timeout = 200,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = false,
    show_on_open_dirs = true,
    debounce = 50,
    icons = {
      hint = '',
      info = '',
      warning = '',
      error = '',
    },
  },
  modified = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
  },
```

- [ ] **Step 2: Smoke-check**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua print('ok')" -c "qa" 2>&1
```
Expected: `ok`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): enable git, diagnostics, modified status"
```

---

### Task 6: Highlights + git fringe signs module

Create the highlight module the spec calls for, hook it into `tree.lua`, and re-apply on `ColorScheme`.

**Files:**
- Create: `nvim/lua/ui/treemacs_highlights.lua`
- Modify: `nvim/lua/config/cores/tree.lua` (require + `ColorScheme` autocmd)

- [ ] **Step 1: Create the highlights module**

Write `nvim/lua/ui/treemacs_highlights.lua`:

```lua
-- Treemacs-flavored highlights and git fringe signs for nvim-tree.
-- Idempotent: safe to call repeatedly (e.g. on ColorScheme).

local M = {}

local function hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

local function get_fg(group, fallback)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h.fg then return h.fg end
  return fallback
end

local function get_bg(group, fallback)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h.bg then return h.bg end
  return fallback
end

local function darken(color, amount)
  if type(color) ~= 'number' then return color end
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256
  r = math.max(0, r - amount)
  g = math.max(0, g - amount)
  b = math.max(0, b - amount)
  return r * 65536 + g * 256 + b
end

function M.apply()
  local normal_bg = get_bg('Normal', 0x1a1b26)
  local tree_bg = darken(normal_bg, 8)
  local cursor_bg = get_bg('CursorLine', 0x292e42)
  local accent_magenta = get_fg('Keyword', 0xbb9af7)
  local accent_blue = get_fg('Function', 0x7aa2f7)
  local accent_green = get_fg('String', 0x9ece6a)
  local accent_yellow = get_fg('WarningMsg', 0xe0af68)
  local accent_red = get_fg('ErrorMsg', 0xf7768e)
  local accent_cyan = get_fg('Special', 0x7dcfff)
  local comment_fg = get_fg('Comment', 0x565f89)

  hl('NvimTreeNormal', { bg = tree_bg })
  hl('NvimTreeNormalNC', { bg = tree_bg })
  hl('NvimTreeEndOfBuffer', { bg = tree_bg, fg = tree_bg })
  hl('NvimTreeSignColumn', { bg = tree_bg })
  hl('NvimTreeCursorLine', { bg = cursor_bg })
  hl('NvimTreeCursorLineNr', { bg = cursor_bg, bold = true })

  hl('NvimTreeRootFolder', { fg = accent_magenta, bold = true })
  hl('NvimTreeIndentMarker', { fg = comment_fg })
  hl('NvimTreeFolderIcon', { fg = accent_blue })
  hl('NvimTreeOpenedFolderName', { fg = accent_blue, bold = true })
  hl('NvimTreeClosedFolderName', { fg = accent_blue })
  hl('NvimTreeEmptyFolderName', { fg = comment_fg })
  hl('NvimTreeModifiedFile', { fg = accent_yellow })
  hl('NvimTreeOpenedFile', { fg = accent_blue, italic = true })

  hl('NvimTreeGitDirty', { fg = accent_yellow })
  hl('NvimTreeGitStaged', { fg = accent_green })
  hl('NvimTreeGitNew', { fg = accent_cyan })
  hl('NvimTreeGitDeleted', { fg = accent_red })
  hl('NvimTreeGitIgnored', { fg = comment_fg })
  hl('NvimTreeGitMerge', { fg = accent_red, bold = true })
  hl('NvimTreeGitRenamed', { fg = accent_yellow })

  local sign_bg = tree_bg
  local function sign(name, color)
    vim.fn.sign_define(name, { text = '▎', texthl = name, numhl = name })
    hl(name, { fg = color, bg = sign_bg })
  end
  sign('NvimTreeGitDirtyIcon', accent_yellow)
  sign('NvimTreeGitStagedIcon', accent_green)
  sign('NvimTreeGitNewIcon', accent_cyan)
  sign('NvimTreeGitDeletedIcon', accent_red)
  sign('NvimTreeGitIgnoredIcon', comment_fg)
  sign('NvimTreeGitMergeIcon', accent_red)
  sign('NvimTreeGitRenamedIcon', accent_yellow)
end

function M.attach_autocmd()
  local group = vim.api.nvim_create_augroup('TreemacsHighlights', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function() M.apply() end,
  })
end

return M
```

- [ ] **Step 2: Wire it into `tree.lua`**

Append to the bottom of `nvim/lua/config/cores/tree.lua`:

```lua
local hi = require('ui.treemacs_highlights')
hi.apply()
hi.attach_autocmd()

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    vim.opt_local.cursorline = true
    vim.opt_local.winhighlight = table.concat({
      'Normal:NvimTreeNormal',
      'NormalNC:NvimTreeNormalNC',
      'EndOfBuffer:NvimTreeEndOfBuffer',
      'CursorLine:NvimTreeCursorLine',
      'SignColumn:NvimTreeSignColumn',
    }, ',')
  end,
})
```

- [ ] **Step 3: Smoke-check that highlights apply without error**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua print(vim.api.nvim_get_hl(0, { name = 'NvimTreeRootFolder' }).bold and 'ok' or 'no-bold')" \
  -c "qa" 2>&1
```
Expected: prints `ok` (the root-folder highlight is bold).

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/ui/treemacs_highlights.lua nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): treemacs highlights + git fringe signs (theme-aware)"
```

---

### Task 7: `on_attach` keymaps

Mirror the current neo-tree keymaps so muscle memory survives.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (add `on_attach` to the `setup` table)

- [ ] **Step 1: Define the `on_attach` function and pass it to `setup`**

Place this **before** the `nvim_tree.setup({...})` call:

```lua
local function on_attach(bufnr)
  local api = require('nvim-tree.api')
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, {
      buffer = bufnr, noremap = true, nowait = true, silent = true, desc = desc,
    })
  end

  -- Open / navigate
  map('l', api.node.open.edit, 'open')
  map('<2-LeftMouse>', api.node.open.edit, 'open')
  map('<CR>', api.node.open.edit, 'open')
  map('P', api.node.open.preview, 'preview')
  map('s', api.node.open.horizontal, 'open: split')
  map('v', api.node.open.vertical, 'open: vsplit')
  map('t', api.node.open.tab, 'open: tab')
  map('w', api.node.open.edit, 'open: window-picker')
  map('<esc>', api.node.navigate.parent_close, 'close node / parent')
  map('C', api.node.navigate.parent_close, 'close node')
  map('z', api.tree.collapse_all, 'collapse all')

  -- Filesystem ops
  map('a', api.fs.create, 'add file')
  map('A', function()
    api.fs.create()
  end, 'add directory (append "/" when prompted)')
  map('d', api.fs.remove, 'delete')
  map('r', api.fs.rename, 'rename')
  map('b', api.fs.rename_basename, 'rename basename')
  map('y', api.fs.copy.node, 'clipboard: copy')
  map('x', api.fs.cut, 'clipboard: cut')
  map('p', api.fs.paste, 'clipboard: paste')
  map('c', api.fs.copy.absolute_path, 'copy absolute path')
  map('m', api.fs.rename_full, 'move (rename full path)')

  -- Window
  map('q', api.tree.close, 'close window')
  map('R', api.tree.reload, 'reload tree')
  map('?', api.tree.toggle_help, 'help')
  map('i', api.node.show_info_popup, 'file details')
  map('H', api.tree.toggle_hidden_filter, 'toggle hidden')
end
```

Then add `on_attach = on_attach,` as the **first** key inside the `nvim_tree.setup({...})` table.

- [ ] **Step 2: Smoke-check load**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" -c "lua print('ok')" -c "qa" 2>&1
```
Expected: `ok`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): on_attach keymaps mirroring neo-tree muscle memory"
```

---

### Task 8: Custom `copy_selector` (the `Y` key)

Re-implement neo-tree's `copy_selector` for nvim-tree.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (define helper, bind `Y` inside `on_attach`)

- [ ] **Step 1: Add the `copy_selector` helper above `on_attach`**

Place this above the `on_attach` definition:

```lua
local function copy_selector()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node then return end
  local filepath = node.absolute_path
  local filename = vim.fn.fnamemodify(filepath, ':t')
  local modify = vim.fn.fnamemodify

  local vals = {
    ['BASENAME'] = modify(filename, ':r'),
    ['EXTENSION'] = modify(filename, ':e'),
    ['FILENAME'] = filename,
    ['PATH (CWD)'] = modify(filepath, ':.'),
    ['PATH (HOME)'] = modify(filepath, ':~'),
    ['PATH'] = filepath,
    ['URI'] = vim.uri_from_fname(filepath),
  }

  local options = vim.tbl_filter(function(val)
    return vals[val] ~= ''
  end, vim.tbl_keys(vals))
  if vim.tbl_isempty(options) then
    vim.notify('No values to copy', vim.log.levels.WARN)
    return
  end
  table.sort(options)
  vim.ui.select(options, {
    prompt = 'Choose to copy to clipboard:',
    format_item = function(item)
      return ('%s: %s'):format(item, vals[item])
    end,
  }, function(choice)
    if not choice then return end
    local result = vals[choice]
    if result then
      vim.notify(('Copied: `%s`'):format(result))
      vim.fn.setreg('+', result)
    end
  end)
end
```

- [ ] **Step 2: Bind `Y` inside `on_attach`**

Inside the `on_attach` function (after the `H` mapping), add:

```lua
  map('Y', copy_selector, 'copy path / name (selector)')
```

- [ ] **Step 3: Smoke-check load**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" -c "lua print('ok')" -c "qa" 2>&1
```
Expected: `ok`.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): port copy_selector custom command from neo-tree"
```

---

### Task 9: Snacks rename hook

Hook `Snacks.rename.on_rename_file` to nvim-tree's rename events so LSP `did_rename` keeps firing on tree-driven renames.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (subscribe after `nvim_tree.setup`)

- [ ] **Step 1: Subscribe to rename events**

Append (after the `setup` call but before the highlight requires):

```lua
local Event = require('nvim-tree.api').events.Event
require('nvim-tree.api').events.subscribe(Event.NodeRenamed, function(data)
  if Snacks and Snacks.rename and Snacks.rename.on_rename_file then
    Snacks.rename.on_rename_file(data.old_name, data.new_name)
  end
end)
require('nvim-tree.api').events.subscribe(Event.FileRenamed, function(data)
  if Snacks and Snacks.rename and Snacks.rename.on_rename_file then
    Snacks.rename.on_rename_file(data.old_name, data.new_name)
  end
end)
```

- [ ] **Step 2: Smoke-check load**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" -c "lua print('ok')" -c "qa" 2>&1
```
Expected: `ok`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): wire Snacks.rename to NodeRenamed/FileRenamed events"
```

---

### Task 10: `gg` → Snacks.lazygit + `<leader>tw` → ChangeRoot

Rebind the dropped `gg` chord to lazygit (in-tree only) and add the workspace-switch substitute as a global leader map.

**Files:**
- Modify: `nvim/lua/config/cores/tree.lua` (add `gg` inside `on_attach`; add `<leader>tw` global map at the bottom)

- [ ] **Step 1: Add `gg` inside `on_attach`**

Inside the `on_attach` function (after the `Y` mapping from Task 8), add:

```lua
  map('gg', function()
    if Snacks and Snacks.lazygit then
      Snacks.lazygit()
    else
      vim.notify('Snacks.lazygit not available', vim.log.levels.WARN)
    end
  end, 'lazygit')
```

- [ ] **Step 2: Add the global `<leader>tw` map at the bottom of `tree.lua`**

Append:

```lua
vim.keymap.set('n', '<leader>tw', function()
  vim.ui.input({ prompt = 'New tree root: ', completion = 'dir', default = vim.fn.getcwd() }, function(input)
    if not input or input == '' then return end
    require('nvim-tree.api').tree.change_root(vim.fn.fnamemodify(input, ':p'))
  end)
end, { desc = 'nvim-tree: change root (workspace switch)' })
```

- [ ] **Step 3: Smoke-check load**

Run:
```bash
nvim --headless -c "lua require('config.cores.tree')" \
  -c "lua print(vim.fn.maparg('<leader>tw', 'n') ~= '' and 'mapped' or 'missing')" \
  -c "qa" 2>&1
```
Expected: prints `mapped`.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/cores/tree.lua
git commit -m "feat(nvim/tree): bind gg to lazygit, <leader>tw to change-root"
```

---

### Task 11: Manual smoke test (full checklist from spec)

This task is **manual** — open Neovim interactively and confirm each item. Do not commit anything until all pass.

**Files:** none (verification only)

- [ ] **Step 1: Open Neovim in the repo**

Run: `nvim` (in `/Users/louishuyng/.dotfiles`)

- [ ] **Step 2: Walk the spec's smoke checklist**

Confirm each:

1. `:NvimTreeToggle` opens left, ~36 cols wide, visibly dimmer background than the editor, root row reads `▾ .dotfiles`.
2. Indent markers render as connected `│ ├ ╰` (not dotted).
3. With the tree open, edit a tracked file in another window and `:w` it → yellow `▎` fringe appears on its row in the tree within ~50ms.
4. Open a buffer not currently focused in the tree (`:e nvim/init.lua`) → tree cursor jumps to it.
5. Press `r` in the tree on any file, type a new name → no errors. (LSP `did_rename` firing is verified by inserting a one-off `print('rename', data.old_name, data.new_name)` inside the Snacks subscription in Task 9, confirming, then removing it.)
6. Press `w` on a file row → window-picker overlay appears (single-letter labels in each window).
7. Press `gg` inside the tree → `Snacks.lazygit` opens.
8. Press `Y` on a file row → `vim.ui.select` prompts with BASENAME / EXTENSION / FILENAME / PATH variants.
9. Run `:checkhealth nvim-tree` → no errors or warnings (warnings about optional features are OK).
10. Run `:colorscheme tokyonight-night` (or whatever your active TN variant is) → tree highlights remain applied (no flash to default).

If any step fails, stop and fix it (revisiting the relevant earlier task), then re-run from Step 1 of Task 11.

- [ ] **Step 3: When all 10 steps pass, mark this task complete**

No commit needed for this task — it is a verification gate.

---

### Task 12: Verify nui.nvim still has a consumer; clean stray references

Defensive check that we did not leave dead references to neo-tree or its support files.

**Files:**
- Read-only: `nvim/lua/config/pack.lua`, all of `nvim/`

- [ ] **Step 1: Confirm nui still has a live consumer**

Run: `grep -rEn "require\\(['\"]nui" nvim/ 2>/dev/null; grep -rEn "neogit\\|noice" nvim/lua/config/pack.lua`
Expected: at least one match. (Neogit pulls nui internally; if nothing in our files calls `require('nui...')` directly that's fine — the manifest entry is still load-bearing for Neogit.)

If no consumer exists at all (Neogit no longer in pack.lua and no `require('nui...')`), open a follow-up to remove `MunifTanjim/nui.nvim` from the manifest. Otherwise leave it.

- [ ] **Step 2: Confirm nothing still imports neo-tree**

Run: `grep -rEn "neo-tree|require\\(['\"]neo-tree" nvim/ 2>/dev/null`
Expected: no results.

If results exist, remove them.

- [ ] **Step 3: Commit any cleanup, or skip this commit if no changes**

```bash
# Only if Step 2 produced edits:
git add nvim/
git commit -m "chore(nvim): drop stray neo-tree references after nvim-tree swap"
```

---

## Self-Review Notes

- **Spec coverage:**
  - Trait a (root chevron): Task 3 (`root_folder_label`) + Task 6 (bold magenta)
  - Trait b (colored icons): Task 3 (`web_devicons.file.color`)
  - Trait c (connected indent guides): Task 3 (`indent_markers`)
  - Trait d (git fringe): Task 3 (`git_placement = 'signcolumn'`) + Task 6 (`▎` signs with theme colors)
  - Trait e (workspaces, deferred): Task 10 (`<leader>tw` ChangeRoot substitute)
  - Trait f (filewatch): Task 4 (`filesystem_watchers`)
  - Trait g (follow current file): Task 4 (`update_focused_file`)
  - Trait h (dense fixed-width sidebar + cursorline): Task 3 (`view.width`) + Task 6 (`FileType NvimTree` autocmd setting cursorline)
  - Snacks rename hook preserved: Task 9
  - `copy_selector` preserved: Task 8
  - Source switcher / git-mode keys / order-by keys dropped: implicitly via Task 7 (only listed keymaps survive)
  - `<leader>tw`, `gg` rebinds: Task 10
  - `nui.nvim` cleanup gated on real check: Task 12

- **Placeholder scan:** None. Every step contains exact code or exact commands. The one "manual" step (Task 11) is explicitly a verification gate, not implementation.

- **Type / API consistency:** All `api.fs.*`, `api.tree.*`, `api.node.*`, and `Event.*` names used in Tasks 7–10 match the [nvim-tree.lua API surface as of upstream main](https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt). `copy_selector` reads `node.absolute_path` (nvim-tree's field name), not `node:get_id()` (neo-tree's). Snacks subscriptions use `data.old_name` / `data.new_name`, the documented field names for `Event.NodeRenamed` / `Event.FileRenamed`.
