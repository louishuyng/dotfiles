---
date: 2026-04-30
topic: Replace neo-tree with nvim-tree styled as Emacs Treemacs
status: design
---

# Replace neo-tree with nvim-tree.lua styled as Treemacs

## Goal

Swap the current `nvim-neo-tree/neo-tree.nvim` sidebar for `nvim-tree/nvim-tree.lua`,
configured to closely match the visual feel of Emacs **Treemacs** (doom-themed
project-roots tree with colored icons, connected indent guides, and a git
status fringe).

The user explicitly chose to switch the underlying library (not restyle
neo-tree). Switching makes some Treemacs traits easier to nail (filewatch,
follow-file, root-folder header) and forfeits one (multi-workspace roots).

## Non-goals

- Multi-root workspaces inside a single tree (Treemacs trait `e`). Out of scope
  for v1; mitigated by a `:NvimTreeChangeRoot`-bound keymap.
- Replacing the buffer source switcher (filesystem / git_status / buffers tabs).
  Dropped — buffers are visible in the tabline; git lives in `Snacks.lazygit`.
- Replacing `oil.nvim` or `Snacks.explorer`. Both stay installed; this spec only
  touches the persistent sidebar tree.

## Treemacs traits and how each maps

| Trait | nvim-tree mechanism |
|---|---|
| **a.** Root header w/ chevron | `renderer.root_folder_label = function(p) return "▾ " .. vim.fn.fnamemodify(p, ":t") end`; `NvimTreeRootFolder` highlight bold + accent |
| **b.** Doom-themed colored icons | `renderer.icons.web_devicons.file.color = true`; nvim-web-devicons (already installed) |
| **c.** Connected indent guides | `renderer.indent_markers = { enable = true, inline_arrows = true, icons = { corner = "╰", edge = "│", item = "├", bottom = "─", none = " " } }` |
| **d.** Git fringe bar | `renderer.icons.git_placement = "signcolumn"`; `vim.fn.sign_define` per status with `text = "▎"` |
| **e.** Workspaces (multi-root) | Out of scope for v1; `<leader>tw` calls `:NvimTreeChangeRoot` |
| **f.** Filewatch auto-refresh | `filesystem_watchers = { enable = true, debounce_delay = 50 }` |
| **g.** Follow current file | `update_focused_file = { enable = true, update_root = false }` |
| **h.** Dense, fixed-width sidebar | `view = { width = 36, side = "left", signcolumn = "yes" }`; `cursorline` set in tree buffer |

## Architecture / file changes

- **`nvim/lua/config/pack.lua`**
  - Remove the `nvim-neo-tree/neo-tree.nvim` entry.
  - Add `nvim-tree/nvim-tree.lua`.
  - Add `s1n7ax/nvim-window-picker` (used by the `w` keymap; was previously
    pulled transitively via neo-tree).
  - Leave `nvim-tree/nvim-web-devicons` (already present).
  - Leave `MunifTanjim/nui.nvim` only if other plugins still need it; otherwise
    remove. (To check during implementation.)

- **`nvim/lua/config/cores/tree.lua`** — full rewrite. Same require site
  (loaded by `config/init.lua`). Sets up nvim-tree with the trait-mapping above
  and the keymaps below. Subscribes to `Event.NodeRenamed` /
  `Event.FileRenamed` so the existing `Snacks.rename.on_rename_file` hook
  continues to run on renames.

- **`nvim/lua/ui/treemacs_highlights.lua`** — new file. Defines the visual
  treatments listed below and re-applies them on every `ColorScheme` autocmd so
  Tokyo Night reloads don't wipe them. Required from `tree.lua` after
  `nvim-tree.setup`.

No other files change. `init.lua`, leader maps, sesh, tmux, and Snacks all stay
put.

## Visual styling (`treemacs_highlights.lua`)

Applied on `ColorScheme` and once on load.

- **Window dressing.** Tree buffer's `winhighlight` is set to
  `Normal:NvimTreeNormal,NormalNC:NvimTreeNormalNC,EndOfBuffer:NvimTreeEndOfBuffer,CursorLine:NvimTreeCursorLine,SignColumn:NvimTreeSignColumn`.
  `NvimTreeNormal` background is one shade darker than the editor `Normal` bg
  (sampled from Tokyo Night palette).
- **Root header.** `NvimTreeRootFolder` → bold, Tokyo Night `magenta` foreground.
- **Indent guides.** `NvimTreeIndentMarker` → muted gray (`Comment` foreground).
- **Folder icons / names.** `NvimTreeFolderIcon` and `NvimTreeOpenedFolderName`
  → Tokyo Night blue. Closed folders inherit `Directory`.
  `NvimTreeEmptyFolderName` is dimmed.
- **Git fringe.** Sign glyph `▎`. Status → color:
  - dirty → yellow
  - staged → green
  - new / untracked → cyan
  - deleted → red
  - ignored → comment gray
  - merge → red, bold
  All colors are read from current highlights via `nvim_get_hl` so the fringe
  follows the active theme.
- **Cursorline.** `NvimTreeCursorLine` background = Tokyo Night `bg_highlight`
  (a few stops above tree bg) for a strong highlight.
- **Modified file.** `NvimTreeModifiedFile` → yellow, matching the statusline's
  modified-buffer color (commit `0dc4d18a`).

## Keymaps (in-tree)

Set via nvim-tree's `on_attach`. Mirrors the current neo-tree keymaps so muscle
memory survives.

| Key | Action |
|---|---|
| `l`, `<2-LeftMouse>` | open node (edit) |
| `<esc>` | close preview / parent navigate |
| `P` | toggle preview (float) |
| `s` | open in horizontal split |
| `v` | open in vertical split |
| `t` | open in new tab |
| `w` | open with `nvim-window-picker` |
| `C` | close node (parent) |
| `z` | collapse all |
| `a` | add file |
| `A` | add directory |
| `d` | delete |
| `r` | rename |
| `b` | rename basename |
| `y` / `x` / `p` | clipboard copy / cut / paste |
| `c` | copy with prompt |
| `m` | move |
| `q` | close window |
| `R` | reload tree |
| `?` | toggle help |
| `i` | show file details popup |
| `Y` | custom `copy_selector` (preserved from neo-tree config) |
| `H` | toggle hidden filter (dotfiles) |
| `gg` | open `Snacks.lazygit` |
| `<leader>tw` (global) | `:NvimTreeChangeRoot` (workspace-switch substitute) |

Source-switcher keys (`<`, `>`) and the git-source-specific keys
(`S/u/s/r/gc/gp`, order-by `oc/od/om/on/os/ot`) are dropped along with the
source switcher itself.

## Behaviors preserved from current config

- **Snacks rename hook.** `api.events.subscribe(Event.NodeRenamed, …)` calls
  `Snacks.rename.on_rename_file(data.old_name, data.new_name)`. Same for
  `FileRenamed`.
- **`copy_selector` command.** Re-implemented as a buffer-local function bound
  to `Y`, calling `api.tree.get_node_under_cursor()` for the path then driving
  `vim.ui.select` exactly as before (BASENAME / EXTENSION / FILENAME / PATH
  variants).
- **No window replacement for terminal/trouble/qf.**
  `actions.open_file.window_picker.exclude` filters those filetypes/buftypes
  (equivalent to neo-tree's `open_files_do_not_replace_types`).

## Behaviors deliberately dropped

- Source switcher tabs (filesystem / document_symbols / git_status).
- The `buffers` source's mini-renderer with diagnostics in the right column.
- File-details columns (size, type, last_modified, created). Available via the
  `i` popup if needed.

## Verification (manual smoke test)

After implementation, run inside Neovim and confirm each:

1. `:NvimTreeToggle` opens left, 36 cols wide, dimmed background, root row
   reads `▾ .dotfiles`.
2. Indent markers render as connected `│ ├ ╰`, not dotted.
3. Edit a tracked file, save → yellow `▎` fringe appears on its row within
   ~50ms (filewatch).
4. Open a buffer that's not under the tree cursor → tree cursor jumps to it
   (follow-file).
5. Rename a file in-tree → LSP `did_rename` fires (verified by a one-off
   `print` inside the `Snacks.rename.on_rename_file` call the first time).
6. `w` triggers the window-picker overlay.
7. `gg` from inside the tree opens `Snacks.lazygit`.
8. `Y` opens the copy-selector `vim.ui.select` picker as before.
9. `:checkhealth nvim-tree` is clean.
10. `:colorscheme tokyonight-night` (reload) → highlights still applied (the
    `ColorScheme` autocmd works).

If any step fails, fix before committing the implementation.

## Open risks

- **`nui.nvim` removal.** Neo-tree depends on it; other plugins might too.
  Implementation must grep before removing the entry from `pack.lua`.
- **Window-picker keymap collision.** `s1n7ax/nvim-window-picker` registers no
  global maps by default but ships with example bindings; we'll set
  `selection_chars` and leave it otherwise headless.
- **Theme drift.** If the user later switches off Tokyo Night, the highlight
  module reads palette via `nvim_get_hl`, so it should adapt — but the
  fringe-bar colors should be re-tested on theme change.
