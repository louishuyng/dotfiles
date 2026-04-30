# Neovim Keybindings

Leader key: `<space>` | Localleader: `,`

## Editor Flow

| Key | Action |
|-----|--------|
| `<leader>w` | Save buffer |
| `<leader>W` | Save all buffers |
| `<leader>q` | Quit |
| `<C-h/j/k/l>` | Navigate windows |
| `,s` | Split horizontal |
| `,v` | Split vertical |
| `<leader>rs` | Resize mode (hjkl, ESC/q to exit) |
| `,q` | Previous buffer |
| `,w` | Next buffer |
| `,bd` | Close tab |
| `,bda` | Close all buffers |
| `<BS>` | Toggle recent buffer |
| `<S-t>` | New tab |
| `<C-x>` (visual) | Cut to system clipboard |
| `<C-c>` (visual) | Yank to system clipboard |
| `/` (visual) | Search word under selection |
| `,m` (visual) | Apply macro to selection |
| `<S-j>/<S-k>` (visual) | Move block down/up |
| `<leader>so` (visual) | Sort selection |
| `<leader>ou` | Open URL under cursor |
| `p` (visual) | Paste without yanking |
| `;r` | Replace word under cursor |
| `<leader>lu` | Update packages |
| `<leader>rb` | Reload buffer + LSP restart |

## File Finding (Telescope)

| Key | Action |
|-----|--------|
| `<C-p>` | Find files |
| `<leader>fi` | Find files (include ignored) |
| `<leader>/` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fm` | List marks |
| `<leader>fj` | Jump list |
| `<leader>fr` | Recent files (project) |
| `<leader>fR` | Recent files (all) |
| `<leader>f/` | Search in current buffer |
| `<leader>fl` | Resume last search |
| `<leader>fa` | List HTTP API files |
| `<leader>fn` | Notification history |
| `<leader>vc` | Find vim configs |
| `<leader>ct` | Choose theme |
| `<leader><BS>` | List keymaps |
| `<leader>"` | List registers |
| `g?` | Help tags |
| `,e` | File browser at current path |

## File Tree (Neo-tree)

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle tree |
| `,nf` | Focus current file in tree |
| `,cr` | Reset to project root |
| `,cd` | Set dir to current file |
| `a` | New file (in tree) |
| `A` | New directory (in tree) |
| `D` | Delete (in tree) |
| `r` | Rename (in tree) |
| `-` | Open Oil (parent directory) |

## Outline (Aerial)

| Key | Action |
|-----|--------|
| `<leader>a` | Toggle Aerial (outline) |
| `{` (in aerial) | Previous symbol |
| `}` (in aerial) | Next symbol |

## Code Search (CtrlSF)

| Key | Action |
|-----|--------|
| `<C-f>f` | Open find prompt |
| `<C-f>w` | Find word under cursor |
| `<C-f>` (visual) | Find selected text |
| `<C-f>t` | Toggle find results |

## Find & Replace

| Key | Action |
|-----|--------|
| `<leader>R` | Toggle Spectre |

## Code Runner

| Key | Action |
|-----|--------|
| `<leader>rr` | Run code |
| `<leader>rf` | Run file |
| `<leader>rft` | Run file in tab |
| `<leader>rp` | Run project |
| `<leader>rc` | Close runner |

## Motion (Flash)

| Key | Action |
|-----|--------|
| `s` | Flash jump |
| `S` | Flash treesitter |
| `r` (operator) | Remote flash |
| `R` | Treesitter search |

## LSP

| Key | Action |
|-----|--------|
| `gf` | Go to definition |
| `gd` | Go to declaration |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `gv` | Go to definition (vsplit) |
| `gS` | Document symbols |
| `gr` | Find references |
| `gl` | Line diagnostics (float) |
| `<leader>ca` | Code action |
| `,rr` | Rename symbol |
| `<leader>fd` | Toggle diagnostics (Trouble) |
| `<leader>oi` | Organize imports (TS) |
| `,l` | Trigger lint |

## Git (Gitsigns + Neogit + Diffview)

| Key | Action |
|-----|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hi` | Preview hunk inline |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this (HEAD) |
| `<leader>hQ` | Set qflist (all hunks) |
| `<leader>hq` | Set qflist (current hunk) |
| `<leader>tb` | Toggle line blame |
| `,gb` | Blame panel |
| `ih` (text obj) | Select hunk |
| `<leader>G` | Git changes quickfix |
| `,gs` | Git status (neogit) |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gS` | Git stash |
| `<leader>gw` | Git worktree |
| `<leader>ga` | Add new git worktree |
| `<leader>gl` | Git log |
| `<leader>gs` | Git status (telescope) |
| `<leader>dvf` | Diff current file |
| `<leader>dva` | Diff project |
| `<leader>dvo` | Open diff |
| `<leader>dvc` | Close diff |
| `<leader>dvl` | Line history |
| `<leader>1` | Reload SSH key |
| `<leader>go` | Open git URL in browser |

## Conflict Resolution

| Key | Action |
|-----|--------|
| `<leader>cb` | Take both |
| `<leader>ci` | Take theirs |
| `<leader>ch` | Take ours |
| `<leader>cn` | Take none |
| `<leader>co` | Conflict list (qf) |

## Debug (DAP)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue/Run |
| `<leader>dC` | Run to cursor |
| `<leader>dg` | Goto line (no execute) |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dO` | Step over |
| `<leader>dk` | Up stack frame |
| `<leader>dj` | Down stack frame |
| `<leader>dt` | Terminate |
| `<leader>dr` | Toggle REPL |
| `<leader>ds` | Session |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval expression |
| `<leader>dw` | Widget hover |
| `<leader>dP` | Pause |

## Test

| Key | Action |
|-----|--------|
| `<space>ts` | Test nearest |
| `<space>tf` | Test file |
| `<space>tl` | Test last |
| `<space>ta` | Test suite |
| `<space>tv` | Test visit |
| `,a` | Toggle file ↔ test file (TS / Go / Ruby / Python) |

## Terminal

| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle terminal |
| `<leader>th` | Terminal horizontal |
| `<leader>tv` | Terminal vertical |
| `<Esc><Esc>` | Exit terminal mode |

## Marks / File Index (Marlin)

| Key | Action |
|-----|--------|
| `;a` | Add file to index |
| `]f` | Next index file |
| `[f` | Previous index file |
| `<leader><leader>` | Toggle last index |
| `<C-e>` | Telescope marlin |

## Quickfix

| Key | Action |
|-----|--------|
| `,qo` | Open quickfix |
| `,qc` | Clear & close quickfix |

## Folding

| Key | Action |
|-----|--------|
| `zl` | Set foldlevel |

## Todo / Misc

| Key | Action |
|-----|--------|
| `]t` | Next todo comment |
| `<leader>td` | List todo (telescope) |
| `<leader>ut` | Toggle undo tree |
| `<C-w>o` | Zen mode |
| `<leader>un` | Dismiss notifications |

## Network

| Key | Action |
|-----|--------|
| `,ni` | Show local IP |
| `,nI` | Show public IP |

## Operator-pending

| Key | Action |
|-----|--------|
| `p` (operator) | `i(` — change inside parens |
