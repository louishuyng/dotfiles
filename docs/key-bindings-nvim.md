# Neovim Keybindings

Leader key: `<space>` | Prefix: `,`

## Editor Flow

| Key | Action |
|-----|--------|
| `<leader>w` | Save buffer |
| `<leader>W` | Save all buffers |
| `<leader>q` | Quit |
| `<C-h/j/k/l>` | Navigate windows |
| `,s` | Split vertical |
| `,v` | Split horizontal |
| `,q` | Previous buffer |
| `,w` | Next buffer |
| `,bd` | Close buffer |
| `,bda` | Close all buffers |
| `<BS>` | Toggle recent buffer |

## File Finding

| Key | Action |
|-----|--------|
| `<C-p>` | Find files |
| `<leader>/` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fm` | List marks |
| `<leader>fj` | Jump list |
| `<leader>fr` | Recent files (project) |
| `<leader>fR` | Recent files (all) |
| `<leader>f/` | Search in buffer |
| `<leader>fl` | Resume last search |
| `,e` | File browser |
| `<leader>fn` | Notification history |

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

## Outline

| Key | Action |
|-----|--------|
| `<leader>s` | Toggle Aerial (outline) |

## LSP

| Key | Action |
|-----|--------|
| `gf` | Go to definition |
| `gd` | Go to declaration |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `gv` | Go to definition (vsplit) |
| `gs` | Document symbols |
| `gr` | Find references |
| `<leader>ca` | Code action |
| `,rr` | Rename symbol |
| `gl` | Line diagnostics (float) |
| `<leader>fd` | Toggle diagnostics (Trouble) |
| `<leader>oi` | Organize imports (TS) |

## Git

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
| `<leader>tb` | Toggle line blame |
| `,gb` | Blame panel |
| `<leader>hd` | Diff this |
| `<leader>G` | Git changes quickfix |
| `,gs` | Git status (neogit) |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gl` | Git log |
| `<leader>gs` | Git status (telescope) |
| `<leader>dvf` | Diff current file |
| `<leader>dva` | Diff project |
| `<leader>dvl` | Line history |

## Debug (DAP)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue/Run |
| `<leader>dC` | Run to cursor |
| `<leader>da` | Run with args |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dO` | Step over |
| `<leader>dk` | Up stack frame |
| `<leader>dj` | Down stack frame |
| `<leader>dt` | Terminate |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval expression |
| `<leader>dP` | Pause |

## Test

| Key | Action |
|-----|--------|
| `<space>ts` | Test nearest |
| `<space>tf` | Test file |
| `<space>tl` | Test last |
| `<space>ta` | Test suite |
| `<space>tv` | Test visit |
| `,a` | Toggle between file and test file (TS / Go / Ruby) |

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

## Find & Replace

| Key | Action |
|-----|--------|
| `<leader>R` | Toggle Spectre |
| `<C-f>f` | Open find prompt (CtrlSF) |
| `<C-f>w` | Find word under cursor |
| `<C-f>t` | Toggle find results |

## Misc

| Key | Action |
|-----|--------|
| `<leader>ut` | Toggle undo tree |
| `<C-w>o` | Zen mode |
| `<leader>go` | Open git URL in browser |
| `;r` | Replace word |
| `<leader><BS>` | List keymaps |
| `<leader>"` | List registers |
