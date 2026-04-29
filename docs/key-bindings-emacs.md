# Doom Emacs Keybindings

Mirror of `key-bindings-nvim.md` for Doom Emacs. Leader key matches nvim:
`SPC` (space) for global leader, `,` for localleader. Status flags:

- ✅ exact parity with nvim
- ⚠️ partial parity (different feel — see notes)
- 🆕 emacs-only addition (no nvim equivalent, kept for ergonomics)

## Editor Flow

| Key | Action | Status |
|-----|--------|--------|
| `SPC w` | Save buffer | ✅ |
| `SPC W` | Save all buffers | ✅ |
| `SPC q` | Quit buffer | ✅ |
| `C-h/j/k/l` | Navigate windows | ✅ |
| `,s` | Split horizontal | ✅ |
| `,v` | Split vertical | ✅ |
| `SPC r s` | Resize hydra (hjkl, q to exit) | ✅ |
| `,q` | Previous buffer | ✅ |
| `,w` | Next buffer | ✅ |
| `,b d` | Close tab | ✅ |
| `,b A` | Close all buffers (renamed from `,bda` — prefix conflict) | ⚠️ |
| `<backspace>` | Switch to last buffer | ✅ |
| `S-t` | New tab | ✅ |
| `C-x` (visual) | Cut to clipboard | ✅ |
| `C-c` (visual) | Yank to clipboard | ✅ |
| `/` (visual) | Search word forward | ✅ |
| `,m` (visual) | Apply last macro | ⚠️ |
| `S-j/S-k` (visual) | Move block down/up (drag-stuff) | ✅ |
| `SPC s o` (visual) | Sort lines | ✅ |
| `SPC o u` | Open URL at point | ✅ |
| `p` (visual) | Paste without yanking | ✅ |
| `;r` | Replace word at point (query-replace) | ⚠️ |
| `SPC l u` | Update packages | ✅ |
| `SPC r b` | Reload buffer + LSP restart | ✅ |

## File Finding (Vertico/Consult)

| Key | Action | Status |
|-----|--------|--------|
| `C-p` | Find files | ✅ |
| `SPC f i` | Find files (no ignore) | ✅ |
| `SPC /` | Project search (consult-ripgrep) | ✅ |
| `SPC f b` | Switch buffer | ✅ |
| `SPC f m` | Consult marks | ✅ |
| `SPC f j` | Show jumps | ⚠️ |
| `SPC f r` | Recent files (project) | ✅ |
| `SPC f R` | Recent files (all) | ✅ |
| `SPC f /` | Search current buffer (consult-line) | ✅ |
| `SPC f l` | Resume last picker (vertico-repeat) | ✅ |
| `SPC v c` | Find dotfiles configs | ✅ |
| `SPC c t` | Choose theme | ✅ |
| `SPC <backspace>` | Describe bindings | ✅ |
| `SPC "` | Consult register | ✅ |
| `g ?` | Helpful symbol | ✅ |
| `,e` | File browser (dired-jump) | ✅ |

## File Tree (Treemacs)

| Key | Action | Status |
|-----|--------|--------|
| `C-\` | Toggle treemacs | ✅ |
| `,n f` | Reveal current file in tree | ✅ |
| `,c r` | Set root to git toplevel | ✅ |
| `,c d` | Set root to current file dir | ✅ |
| `-` | Open dired (parent dir) | ✅ |

## Outline (imenu-list)

| Key | Action | Status |
|-----|--------|--------|
| `SPC a` | Toggle imenu-list | ✅ |

## Code Search

| Key | Action | Status |
|-----|--------|--------|
| `C-f f` | consult-ripgrep | ✅ |
| `C-f w` | Ripgrep word at point | ✅ |
| `C-f` (visual) | Ripgrep selection | ✅ |
| `C-f t` | wgrep edit mode | ⚠️ |

## Find & Replace

| Key | Action | Status |
|-----|--------|--------|
| `SPC R` | Project query-replace-regexp | ⚠️ |

## Code Runner (quickrun)

| Key | Action | Status |
|-----|--------|--------|
| `SPC r r` | quickrun | ✅ |
| `SPC r f` | quickrun (file) | ✅ |
| `SPC r T` | quickrun (in tab — renamed from `rft` to avoid prefix conflict) | ⚠️ |
| `SPC r p` | projectile-run-project | ✅ |
| `SPC r c` | Close runner output | ⚠️ |

## Motion (Avy)

| Key | Action | Status |
|-----|--------|--------|
| `s` | avy-goto-char-2 | ⚠️ |
| `S` | avy-goto-symbol-1 | ⚠️ |
| `r` (operator) | avy-goto-char | ⚠️ |
| `R` | avy-goto-word-1 | ⚠️ |

> ⚠️ avy is conceptually similar to flash but the prompt UX differs (avy shows
> labels per match, flash hints inline). Muscle memory transfers; visual feel
> differs slightly.

## LSP

| Key | Action | Status |
|-----|--------|--------|
| `g f` | +lookup/definition | ✅ |
| `g d` | +lookup/declaration | ✅ |
| `g i` | +lookup/implementations | ✅ |
| `g t` | +lookup/type-definition | ⚠️ |
| `g v` | Vsplit + go to definition | ✅ |
| `g S` | lsp document symbols | ✅ |
| `g r` | +lookup/references | ✅ |
| `g l` | Display error at point | ✅ |
| `SPC c a` | lsp-execute-code-action | ✅ |
| `,r r` | lsp-rename | ✅ |
| `SPC f d` | consult-flymake | ✅ |
| `SPC o i` | lsp-organize-imports (TS) | ✅ |
| `,l` | flycheck-buffer | ✅ |

> ⚠️ `g t` collides with evil's "next tab" — we override since LSP type lookup
> is the more frequent action. Use `tab-bar-switch-to-next-tab` (`C-x t o`)
> for tabs.

## Git (Magit + git-gutter + smerge)

| Key | Action | Status |
|-----|--------|--------|
| `]c` | git-gutter:next-hunk | ✅ |
| `[c` | git-gutter:previous-hunk | ✅ |
| `SPC h s` | git-gutter:stage-hunk | ✅ |
| `SPC h r` | git-gutter:revert-hunk | ✅ |
| `SPC h S` | magit-stage-file | ✅ |
| `SPC h R` | magit-reset-file | ✅ |
| `SPC h p` | git-gutter:popup-hunk | ✅ |
| `SPC h i` | (alias to popup-hunk) | ⚠️ |
| `SPC h b` | magit-blame-addition | ✅ |
| `SPC h d` | magit-diff-buffer-file | ✅ |
| `SPC h D` | Diff against HEAD~ | ⚠️ |
| `SPC h Q` | List repo status (qflist analog) | ⚠️ |
| `SPC h q` | (current hunk qf) | ⚠️ |
| `SPC t b` | magit-blame-toggle | ✅ |
| `i h` (text obj) | git-gutter:mark-hunk | ⚠️ |
| `SPC G` | (git-changed files list) | ⚠️ |
| `,g s` | magit-status | ✅ |
| `SPC g b` | magit-branch | ✅ |
| `SPC g c` | magit-log-current | ✅ |
| `SPC g S` | magit-stash | ✅ |
| `SPC g w` | magit-worktree | ✅ |
| `SPC g a` | magit-worktree-checkout | ✅ |
| `SPC g l` | magit-log | ✅ |
| `SPC g s` | magit-status | ✅ |
| `SPC d v f` | magit-log-buffer-file | ✅ |
| `SPC d v a` | magit-log-all | ✅ |
| `SPC d v o` | magit-diff-buffer-file | ⚠️ |
| `SPC d v c` | magit-mode-bury-buffer | ⚠️ |
| `SPC d v l` | magit-log-trace-definition | ⚠️ |
| `SPC 1` | Reload SSH key (open_source) | ✅ |
| `SPC g o` | browse-at-remote | ✅ |
| `,g b` | magit-blame | ✅ |

## Conflict Resolution (smerge)

| Key | Action | Status |
|-----|--------|--------|
| `SPC c b` | smerge-keep-all | ✅ |
| `SPC c i` | smerge-keep-other | ✅ |
| `SPC c h` | smerge-keep-mine | ✅ |
| `SPC c n` | (custom: keep none) | ⚠️ |
| `SPC c o` | smerge-list / consult-flymake | ⚠️ |

## Debug (dap-mode)

| Key | Action | Status |
|-----|--------|--------|
| `SPC d b` | dap-breakpoint-toggle | ✅ |
| `SPC d B` | dap-breakpoint-condition | ✅ |
| `SPC d c` | dap-continue | ✅ |
| `SPC d C` | (run to cursor) | ⚠️ |
| `SPC d g` | (goto line) | ⚠️ |
| `SPC d i` | dap-step-in | ✅ |
| `SPC d o` | dap-step-out | ✅ |
| `SPC d O` | dap-next | ✅ |
| `SPC d k` | dap-up | ⚠️ |
| `SPC d j` | dap-down | ⚠️ |
| `SPC d t` | dap-disconnect | ✅ |
| `SPC d r` | dap-ui-repl | ✅ |
| `SPC d s` | dap-ui-sessions | ✅ |
| `SPC d l` | dap-debug-last | ✅ |
| `SPC d u` | dap-ui-toggle | ✅ |
| `SPC d e` | dap-eval | ✅ |
| `SPC d w` | dap-hydra | ⚠️ |
| `SPC d P` | dap-pause | ⚠️ |

## Test

| Key | Action | Status |
|-----|--------|--------|
| `SPC t s` | Test nearest (custom) | ⚠️ |
| `SPC t f` | Test file (custom) | ⚠️ |
| `SPC t l` | recompile (test last) | ✅ |
| `SPC t a` | projectile-test-project | ✅ |
| `SPC t v` | Visit last test | ⚠️ |
| `,a` | projectile toggle impl/test | ✅ |

## Terminal (vterm)

| Key | Action | Status |
|-----|--------|--------|
| `SPC t t` | +vterm/toggle | ✅ |
| `SPC t h` | vterm split horizontal | ✅ |
| `SPC t v` | vterm split vertical | ✅ |
| `ESC ESC` (term) | Exit to evil-normal | ✅ |

## Marks / File Index (bookmarks)

| Key | Action | Status |
|-----|--------|--------|
| `;a` | bookmark-set | ⚠️ |
| `]f` | bookmark-jump-next (custom) | ⚠️ |
| `[f` | bookmark-jump-prev (custom) | ⚠️ |
| `SPC SPC` | bookmark-jump | ⚠️ |
| `C-e` | consult-bookmark | ✅ |

## Quickfix (flycheck list)

| Key | Action | Status |
|-----|--------|--------|
| `,q o` | flycheck-list-errors | ✅ |
| `,q c` | (clear & close errors) | ⚠️ |

## Folding

| Key | Action | Status |
|-----|--------|--------|
| `z l` | hs-show-block / set-selective-display | ✅ |

## Todo / Misc

| Key | Action | Status |
|-----|--------|--------|
| `]t` | hl-todo-next | ✅ |
| `SPC t d` | consult-todo | ✅ |
| `SPC u t` | vundo | ✅ |
| `C-w o` | +zen/toggle | ✅ |
| `SPC u n` | Clear popups | ✅ |

## Network

| Key | Action | Status |
|-----|--------|--------|
| `,n i` | Show local IP | ⚠️ |
| `,n I` | Show public IP | ✅ |

## Operator-pending

| Key | Action | Status |
|-----|--------|--------|
| `p` (operator) | `i(` (evil text object) | ✅ |

## Notes on divergence

- **Flash → avy**: avy is the closest analog. The "label per match" UX is a
  little different, but the keys (`s`, `S`, `R`) are unchanged.
- **Telescope → vertico/consult**: Doom defaults to vertico + consult, which
  cover all telescope use cases. `consult-ripgrep`, `consult-line`,
  `consult-buffer`, `consult-mark`, `consult-register` are direct analogs.
- **Neogit → magit**: magit is the canonical Emacs git porcelain (neogit is a
  port). All branches/commits/stash/log/worktree flows work; the keys mostly
  match.
- **Diffview → magit + ediff**: `magit-log-buffer-file` and
  `magit-diff-buffer-file` cover most of the diffview workflow; for
  side-by-side diffs use `ediff`.
- **vim-test → custom shell wrappers**: Doom doesn't bundle a test framework
  out of the box. We hook `compile` and `recompile` for "test last" and
  define small wrappers for "test file" and "test nearest".
- **Marlin → bookmarks**: Emacs bookmarks are persistent and global; marlin
  is per-project and harpoon-style. Good-enough parity for "jump to N
  bookmarked files" but the project scoping differs.
- **Spectre → wgrep + project-query-replace**: not a direct UI match;
  `wgrep` lets you edit `consult-ripgrep` results and write changes back
  across files.
