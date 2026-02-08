# Doom Emacs Configuration

Configuration mirroring Neovim setup with equivalent keybindings.

## Installation

```bash
~/.emacs.d/bin/doom sync
```

---

## Keybindings

### Leader Key
- **Leader**: `SPC` (Space)
- **Local prefix**: `,` (comma) for custom bindings

### Window Navigation

| Neovim | Emacs | Action |
|--------|-------|--------|
| `C-h` | `C-h` | Move to left window |
| `C-j` | `C-j` | Move to down window |
| `C-k` | `C-k` | Move to up window |
| `C-l` | `C-l` | Move to right window |
| `,v` | `,v` | Vertical split |
| `,s` | `,s` | Horizontal split |
| `<leader>rs` | `SPC w r` | Resize mode (h/j/k/l to resize) |

### File Navigation

| Neovim | Emacs | Action |
|--------|-------|--------|
| `C-p` | `C-p` | Find file in project |
| `<leader>SPC` | `SPC SPC` | Find file |
| `<leader>/` | `SPC /` | Search in project (ripgrep) |
| `<leader>fb` | `SPC b b` | List buffers |
| `<leader>fr` | `SPC f r` | Recent files |

### File Explorer

| Neovim | Emacs | Action |
|--------|-------|--------|
| `C-\` | `C-\` | Toggle file tree |
| `,nf` | `,nf` | Focus current file in tree |
| `,e` | `,e` | Open file browser |
| `-` | `-` | Open parent directory (dired) |

### Buffer Navigation

| Neovim | Emacs | Action |
|--------|-------|--------|
| `,q` | `,q` | Previous buffer |
| `,w` | `,w` | Next buffer |
| `,bd` | `,bd` | Close buffer |
| `<Backspace>` | `<Backspace>` | Switch to last buffer |

### Save and Quit

| Neovim | Emacs | Action |
|--------|-------|--------|
| `<leader>w` | `SPC f s` | Save buffer |
| `<leader>q` | `SPC q q` | Quit |

### LSP / Code

| Neovim | Emacs | Action |
|--------|-------|--------|
| `gd` | `gd` | Go to definition |
| `gD` | `gD` | Go to declaration |
| `gr` | `gr` | Find references |
| `gi` | `gi` | Go to implementation |
| `gv` | `gv` | Definition in vertical split |
| `K` | `K` | Hover documentation |
| `]d` | `]d` | Next diagnostic |
| `[d` | `[d` | Previous diagnostic |
| `<leader>ca` | `SPC c a` | Code action |
| `<leader>cr` | `SPC c r` | Rename symbol |
| `<leader>cf` | `SPC c f` | Format buffer |

### Git

| Neovim | Emacs | Action |
|--------|-------|--------|
| `,gs` | `,gs` | Git status (Magit) |
| `<leader>gg` | `SPC g g` | Git status |
| `<leader>gb` | `SPC g b` | Git blame |
| `<leader>gl` | `SPC g l` | Git log |
| `]c` | `]c` | Next hunk |
| `[c` | `[c` | Previous hunk |
| `,hs` | `,hs` | Stage hunk |
| `,hr` | `,hr` | Revert hunk |
| `,hp` | `,hp` | Preview hunk |
| `,gb` | `,gb` | Blame file |
| `,gt` | `,gt` | Git time machine |

### Conflict Resolution

| Neovim | Emacs | Action |
|--------|-------|--------|
| `,ch` | `,ch` | Choose ours (head) |
| `,ci` | `,ci` | Choose theirs (incoming) |
| `,cb` | `,cb` | Choose both |
| `,cn` | `,cn` | Next conflict |
| `,cp` | `,cp` | Previous conflict |

### Testing

| Neovim | Emacs | Action |
|--------|-------|--------|
| `,a` | `,a` | Toggle between impl/test file |
| `<leader>pt` | `SPC p t` | Test project |

### Motion / Jump

| Neovim | Emacs | Action |
|--------|-------|--------|
| `s` | `s` | Jump to 2 chars (avy) |
| `S` | `S` | Jump to word |

### AI Assistance

| Neovim | Emacs | Action |
|--------|-------|--------|
| `,ai` | `,ai` | Open AI chat (gptel) |
| `,as` | `,as` | Send selection to AI |
| `,tc` | `,tc` | Toggle Copilot |
| `C-<tab>` | `C-<tab>` | Accept Copilot suggestion |

### Workspaces

| Neovim | Emacs | Action |
|--------|-------|--------|
| - | `SPC TAB TAB` | Switch workspace |
| - | `SPC TAB n` | New workspace |
| - | `SPC TAB d` | Delete workspace |
| - | `SPC 1-5` | Switch to workspace 1-5 |

### Projects

| Neovim | Emacs | Action |
|--------|-------|--------|
| - | `SPC p p` | Switch project |
| - | `SPC p f` | Find file in project |
| - | `SPC p s` | Search in project |
| - | `SPC p t` | Test project |

---

## Terminal

| Keybinding | Action |
|------------|--------|
| `SPC o t` | Toggle popup terminal |
| `SPC o T` | Open terminal here |
| `<escape>` | Exit terminal mode |
| `C-h/j/k/l` | Navigate windows from terminal |

### Multiple Terminals

1. `SPC o T` → Creates new terminal
2. `SPC b b` → Switch between buffers (including terminals)
3. Each workspace can have its own terminals

---

## Multiple Projects

### Workflow

```
1. SPC TAB n "api"        → Create workspace for API
2. SPC p p               → Select API project
3. SPC o T               → Open terminal

4. SPC TAB n "frontend"   → Create workspace for frontend
5. SPC p p               → Select frontend project

6. SPC 1                  → Switch to API workspace
7. SPC 2                  → Switch to frontend workspace
```

---

## Troubleshooting

```bash
# Check issues
~/.emacs.d/bin/doom doctor

# Reinstall packages
~/.emacs.d/bin/doom sync

# Full rebuild
~/.emacs.d/bin/doom sync --rebuild

# Reset everything
~/.emacs.d/bin/doom purge && ~/.emacs.d/bin/doom sync
```
