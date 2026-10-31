# Zed Keybindings

Leader key: `space` | Prefix: `,`

From the editor in Vim normal mode, panel shortcuts hide the target panel when it
is visible, even when the editor has focus. When hidden, they open the target panel.
If another panel occupies the same dock, they switch to the target panel.
`space s s` is inactive in search forms and search-results views.

## Editor Flow

| Key | Action |
|-----|--------|
| `space w` | Save |
| `space q` | Close active item |
| `ctrl-h/j/k/l` | Navigate panes |
| `, v` | Split right |
| `, s` | Split up |
| `, q` | Previous buffer |
| `, w` | Next buffer |
| `, b d` | Close buffer |
| `, b d a` | Close all items |
| `cmd-s` | Toggle agent panel |
| `ctrl-\` | Toggle project panel |

## File Finding

| Key | Action |
|-----|--------|
| `ctrl-p` | Find files |
| `space /` | New search |
| `ctrl-a s` | Open recent projects |

## File Tree (Project Panel)

| Key | Action |
|-----|--------|
| `space s s` | Toggle outline panel |
| `, g s` | Toggle git panel |
| `a` | New file (in panel) |
| `A` | New directory (in panel) |
| `D` | Delete (in panel) |
| `r` | Rename (in panel) |
| `l` | Open permanent (in panel) |
| `s` | Open split horizontal (in panel) |

## LSP

| Key | Action |
|-----|--------|
| `g f` | Go to definition |
| `g t` | Go to type definition |
| `g v` | Go to definition (split) |
| `space c a` | Code actions |
| `] d` | Next diagnostic |
| `[ d` | Previous diagnostic |

## Git

| Key | Action |
|-----|--------|
| `] h` | Next hunk |
| `[ h` | Previous hunk |
| `space h s` | Toggle staged |
| `space h u` | Unstage and next |
| `space h r` | Restore (reset hunk) |
| `space h p` | Toggle selected diff hunks |
| `space g b` | Toggle git blame inline |
| `, g b` | Git blame panel |
| `, g s` | Toggle git panel |
| `s` | Stage file (in git panel) |
| `shift-s` | Stage all (in git diff) |

## Debug (DAP)

| Key | Action |
|-----|--------|
| `space d b` | Toggle breakpoint |
| `space d d` | Start debug session |
| `space d c` | Continue |
| `space d C` | Run to cursor |
| `space d i` | Step into |
| `space d o` | Step out |
| `space d O` | Step over |
| `space d t` | Stop/Terminate |
| `space d r` | Restart |
| `space d u` | Toggle debug panel |

## Test

| Key | Action |
|-----|--------|
| `space t s` | Run nearest task (test at cursor) |
| `space t f` | Open task picker |
| `space t l` | Rerun last task |
| `, a` | Toggle between file and test file (TS / Go / Ruby) |

## Terminal

| Key | Action |
|-----|--------|
| `ctrl-t` | Toggle terminal panel (workspace) |
| `ctrl-t` | Toggle terminal panel (editor normal mode) |
| `ctrl-t` | Toggle terminal panel (in terminal; preserves the session) |

## AI Assistant

| Key | Context | Action |
|-----|---------|--------|
| `space k` | Editor normal mode | Inline assist |
| `space i` | Editor normal mode | Toggle agent panel |
| `cmd-/` | Global | Toggle agent panel |

## Menu / Completion Navigation

| Key | Context | Action |
|-----|---------|--------|
| `ctrl-j` / `ctrl-n` | Menu | Select next |
| `ctrl-k` / `ctrl-p` | Menu | Select previous |
| `ctrl-j` / `ctrl-n` | Completion/Code Actions | Context menu next |
| `ctrl-k` / `ctrl-p` | Completion/Code Actions | Context menu previous |
