# WezTerm Configuration - tmux Replacement

This WezTerm configuration provides a complete tmux replacement with built-in multiplexing, workspace management, and familiar keybindings.

## Quick Start

Leader key: `Ctrl-a` (same as tmux)

## Concepts

| tmux Concept | WezTerm Equivalent |
|--------------|-------------------|
| Session | Workspace |
| Window | Tab |
| Pane | Pane |

## Keybindings Reference

### Workspace Management (like tmux sessions)

| Key | Action |
|-----|--------|
| `Ctrl-a s` | Switch workspace (fuzzy finder) |
| `Ctrl-a w` | List active workspaces |
| `Ctrl-a Ctrl-c` | Create new workspace |
| `Ctrl-a $` | Rename current workspace |
| `Ctrl-a \` | Switch to last workspace |
| `Ctrl-a o` | Open project as pane (split right) |
| `Ctrl-a O` | Open project as pane (split down) |

### Pane Management

| Key | Action |
|-----|--------|
| `Ctrl-a \|` | Split pane vertically (right) |
| `Ctrl-a -` | Split pane horizontally (down) |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl-a H/J/K/L` | Resize panes |
| `Ctrl-a z` | Toggle pane zoom |
| `Ctrl-a x` | Close pane |

### Tab Management (like tmux windows)

| Key | Action |
|-----|--------|
| `Ctrl-a c` | New tab |
| `Ctrl-a n` | Next tab |
| `Ctrl-a p` | Previous tab |
| `Ctrl-a 1-9` | Go to tab by number |
| `Ctrl-a Tab` | Switch to last tab |
| `Ctrl-a ,` | Rename tab |
| `Ctrl-a <` | Move tab left |
| `Ctrl-a >` | Move tab right |
| `Ctrl-a &` | Close tab |

### Quick Launch

| Key | Action |
|-----|--------|
| `Ctrl-a a` | Quick launcher menu |
| `Ctrl-a g` | Open LazyGit |
| `Ctrl-a i` | Open LazyDocker |
| `Ctrl-a /` | Open SuperFile |

### Copy Mode (vim-style)

| Key | Action |
|-----|--------|
| `Ctrl-a v` or `Ctrl-a [` | Enter copy mode |
| `h/j/k/l` | Navigate |
| `w/b/e` | Word navigation |
| `0/$` | Start/end of line |
| `g/G` | Top/bottom of scrollback |
| `v` | Start selection |
| `V` | Line selection |
| `Ctrl-v` | Block selection |
| `y` | Yank and exit |
| `/` | Search |
| `n/N` | Next/previous match |
| `q` or `Esc` | Exit copy mode |

### Misc

| Key | Action |
|-----|--------|
| `Ctrl-a f` | Search in scrollback |
| `Ctrl-a r` | Reload configuration |
| `Ctrl-a :` | Command palette |
| `Ctrl-a D` | Debug overlay |
| `Cmd-Enter` | Toggle fullscreen |

### macOS Shortcuts

| Key | Action |
|-----|--------|
| `Cmd-t` | New tab |
| `Cmd-w` | Close tab |
| `Cmd-1-9` | Switch to tab |
| `Cmd-[/]` | Previous/next tab |
| `Cmd-+/-/0` | Font size |

## Working with Multiple Projects

### Auto-Grouping (Same Parent Folder)

When you use `Ctrl-a s` to switch projects, WezTerm automatically detects if the selected project is from the **same parent folder** as your current working directory.

- **Same parent** → Opens as a **split pane** (for easy navigation between related projects)
- **Different parent** → Opens as a **new workspace**

**Example:**
```
Current: ~/LX14/repository/github.com/louishuyng/project-a
Select:  ~/LX14/repository/github.com/louishuyng/project-b
Result:  Opens project-b as a pane next to project-a (same parent)

Current: ~/LX14/repository/github.com/louishuyng/project-a
Select:  ~/.dotfiles
Result:  Switches to a new "dotfiles" workspace (different parent)
```

### Explicit Pane Opening

Use these to always open projects as panes (regardless of parent):

| Key | Action |
|-----|--------|
| `Ctrl-a o` | Open project as pane (split right) |
| `Ctrl-a O` | Open project as pane (split down) |

### Method 1: Using Workspace Switcher

1. Press `Ctrl-a s` to open the workspace switcher
2. Type to fuzzy search for your project
3. Press Enter to switch/create workspace (auto-groups same parent)

The switcher automatically scans your configured project directories.

### Method 2: Create Named Workspaces

1. Press `Ctrl-a Ctrl-c` to create a new workspace
2. Enter a name for your workspace
3. Navigate to your project directory

### Method 3: Predefined Workspaces

Edit `workspaces.lua` to add your common projects:

```lua
Workspaces.predefined = {
    { name = "dotfiles", cwd = "~/.dotfiles" },
    { name = "myproject", cwd = "~/Projects/myproject" },
    { name = "work", cwd = "~/Work/main-repo" },
}
```

### Workflow Example

```
1. Start WezTerm (default workspace)
2. Ctrl-a s -> type "dotfiles" -> Enter (creates/switches to dotfiles workspace)
3. Work on dotfiles...
4. Ctrl-a s -> type "myproject" -> Enter (creates/switches to myproject)
5. Work on myproject...
6. Ctrl-a \ -> switch back to previous workspace
7. Ctrl-a w -> see all active workspaces
```

## Status Bar

The status bar shows:
- Left: Number of active workspaces
- Center: Tabs with index and folder name
- Right: Workspace name + time

Indicators:
- `LEADER` - Leader key is active (green)
- `ZOOM` - Current pane is zoomed (red)
- `` - Pane is zoomed (in tab title)

## Customization

### Adding Project Directories

Edit `workspaces.lua`:

```lua
Workspaces.project_dirs = {
    "~/Projects",
    "~/Work",
    "~/personal",
    -- Add more directories here
}
```

### Quick Launch Apps

Edit `workspaces.lua` to add more quick launch options:

```lua
local choices = {
    { id = "lazygit", label = "  LazyGit" },
    { id = "htop", label = "  Htop" },
    -- Add more here
}
```

### Theme Colors

Edit `tabs.lua` to customize status bar colors:

```lua
local colors = {
    bg = "#1C1C20",
    fg = "#d3c6aa",
    workspace_bg = "#59a6c3",
    -- Customize as needed
}
```

## Tips

1. **Fast project switching**: Use `Ctrl-a s` and type a few characters of your project name
2. **Quick git access**: Use `Ctrl-a g` to open lazygit in a new tab
3. **Zoom for focus**: Use `Ctrl-a z` to zoom a pane when you need full screen
4. **Copy scrollback**: Use `Ctrl-a [` to enter copy mode with vim bindings
5. **Command palette**: Use `Ctrl-a :` to access all WezTerm commands

## Migration from tmux

| tmux | WezTerm |
|------|---------|
| `tmux new -s name` | `Ctrl-a Ctrl-c` then enter name |
| `tmux ls` | `Ctrl-a w` |
| `tmux attach -t name` | `Ctrl-a s` then select |
| `tmux kill-session` | Close all tabs in workspace |
| `prefix + d` | Just close the window |

## Files

```
~/.config/wezterm/
├── wezterm.lua      # Main config
├── keys.lua         # Keybindings
├── workspaces.lua   # Workspace management
├── tabs.lua         # Tab bar & status
├── theme.lua        # Colors
└── fonts.lua        # Font settings
```