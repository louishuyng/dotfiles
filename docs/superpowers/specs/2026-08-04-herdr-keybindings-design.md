# herdr keybindings + tmux-parity migration

herdr 0.8.0 replaces tmux as the outer multiplexer. This spec defines its
keybindings (mirroring the existing tmux config so muscle memory carries over),
the fish autostart, and the two tmux-coupled helper scripts that need a herdr
backend.

## Goals

- `ctrl+a` prefix and a key map that matches `terminals/tmux/.tmux.conf` wherever
  herdr has an equivalent action.
- All ten tmux popup/window launchers reachable on their existing keys.
- A project picker equivalent to the sesh picker: pick an already-open project or
  a known-but-closed one, from one list.
- herdr launches automatically in interactive fish shells.
- Config lives in the dotfiles repo, symlinked like every other tool.

## Non-goals

- Retiring tmux. The helper scripts stay dual-backend so tmux keeps working.
- Reproducing tmux actions herdr does not have (see Dropped bindings).

## Constraints discovered

- Key syntax is strict. `prefix+|` and `prefix+$` validate; `prefix+pipe` and
  `prefix+dollar` do not. Every binding below was checked with
  `XDG_CONFIG_HOME=<tmp> herdr config check`, which reads
  `$XDG_CONFIG_HOME/herdr/config.toml` — the way to validate without touching the
  live config.
- `herdr config check` reports invalid bindings as warnings and *disables* them
  rather than failing, so a typo degrades silently. Validation is mandatory.
- Control commands return JSON on stdout; IDs must be read from responses, never
  predicted. `jq` is the parsing dependency.
- `HERDR_ENV=1` is set inside panes. This is the nesting guard for both the fish
  autostart and the script backend switch.

## Key map

### Prefix

```toml
[keys]
prefix = "ctrl+a"
```

No collision, since herdr replaces tmux rather than nesting inside it.

### Inherited unchanged

herdr's defaults already match the tmux config. No entries needed:

`prefix+h/j/k/l` pane focus · `prefix+-` split below · `prefix+z` zoom ·
`prefix+x` close pane · `prefix+c` new tab · `prefix+1..9` switch tab ·
`prefix+?` help · `prefix+b` toggle sidebar · `prefix+w` workspace picker ·
`prefix+o` open notification target · `prefix+shift+x` close tab

### Remapped for tmux parity

| tmux | herdr setting | value |
|---|---|---|
| `\|` split side-by-side | `split_vertical` | `prefix+\|` |
| `C-h` prev window | `previous_tab` | `prefix+ctrl+h` |
| `C-l` next window | `next_tab` | `prefix+ctrl+l` |
| `d` detach | `detach` | `prefix+d` |
| `v` copy-mode | `edit_scrollback` | `prefix+v` |
| `Tab` last window | `last_pane` | `prefix+tab` |
| `C-c` new session | `new_workspace` | `prefix+ctrl+c` |
| `,` rename window | `rename_tab` | `prefix+,` |
| `$` rename session | `rename_workspace` | `prefix+$` |

Two deliberate semantic shifts:

- `prefix+v` opens scrollback in nvim instead of entering a copy-mode. Full vim
  motions and `y` — a superset of the tmux `v`/`y` flow it replaces.
- `prefix+tab` becomes last-*pane*, not last-*window*. herdr has no last-tab
  action; this is the nearest available. `cycle_pane_next` is cleared to free the
  key, since `h/j/k/l` already covers directional movement.
  `cycle_pane_previous` stays at its `prefix+shift+tab` default — unclaimed, and
  harmless to keep.

`prefix+,` matches **stock tmux**, not the current config, which rebound `,` to
`swap-window -t -1`. Tab reordering has no herdr equivalent, so the key frees up
and rename reclaims it.

### Displaced herdr defaults

Moved only because a tmux-parity binding or launcher claims their key:

| setting | herdr default | new value | displaced by |
|---|---|---|---|
| `settings` | `prefix+s` | `prefix+shift+s` | project picker |
| `goto` | `prefix+g` | `prefix+ctrl+g` | gh-dash |
| `reload_config` | `prefix+shift+r` | `prefix+ctrl+shift+r` | serpl |
| `rename_tab` | `prefix+shift+t` | `prefix+,` | theme toggle |

`resize_mode` stays at its `prefix+r` default. The tmux `r` (reload config) is
rare and reachable via `herdr server reload-config`; pressing `r` out of habit
enters resize mode, which is harmless and self-describing.

Also set: `switch_workspace = "prefix+shift+1..9"` (unset by default, no tmux
equivalent, but the natural companion to `switch_tab`).

### Launchers

`[[keys.command]]` blocks, `type = "popup"`, preserving tmux keys and sizing:

| key | command | size |
|---|---|---|
| `prefix+/` | `yazi` | 80% |
| `prefix+i` | `lazydocker` | 80% |
| `prefix+t` | `tuxedo` | 80% |
| `prefix+shift+r` | `serpl` | 80% |
| `prefix+a` | `posting` | 90% |
| `prefix+ctrl+r` | `tuicr` | 90% |
| `prefix+g` | `gh dash` | 90% |
| `prefix+n` | note script | 90% |
| `prefix+p` | playzone picker | 80% |
| `prefix+s` | project picker | 80% |

`gh dash` and the note script were full tmux *windows* because nested TUIs
(tuicr, lazygit, nvim) needed room. herdr popups are session-modal, so 90% is
sufficient and no tab is consumed.

`prefix+p` and `prefix+n` are available precisely because `previous_tab` and
`next_tab` moved to `prefix+ctrl+h/l`.

### Shell-command extras

Two bindings use `type = "shell"` because herdr has no native action:

- **Directional pane swap** — `prefix+left/down/up/right` run `herdr pane swap`
  against `$HERDR_PANE_ID` and the neighbor from `herdr pane neighbor`, mirroring
  the tmux arrow bindings. The tmux version falls back to prev/next pane at an
  edge; the herdr version is a no-op at an edge, since `pane neighbor` returns
  nothing to swap with.
- **Theme toggle (`prefix+shift+t`)** — flips **macOS appearance** via
  `osascript`, not herdr's own theme. See below.

These are the only bindings coupled to herdr's CLI surface rather than its
keybinding schema, so they are the ones a version bump could break.

## Theming

herdr does natively what `terminals/tmux/scripts/switch-theme.sh` hand-rolls:

```toml
[theme]
auto_switch = true
dark_name = "catppuccin"
light_name = "catppuccin-latte"
```

So herdr follows host light/dark appearance with no script, and the existing
`com.user.theme-watcher` launchd daemon remains the single source of truth.

This replaces the originally-planned `prefix+shift+t` binding that rewrote
`theme.name` in `config.toml` and reloaded the server. That approach was wrong on
two counts: `config.toml` is a git-tracked symlink into the dotfiles repo, so
every toggle would dirty the working tree; and it would duplicate appearance
tracking that already exists.

`prefix+shift+t` stays bound, but toggles macOS appearance itself:

```
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
```

herdr, Ghostty, nvim, and tmux then all follow via the existing daemon — one
system-wide toggle rather than a herdr-local one. Strictly broader than the tmux
`T` binding it replaces, on the same key.

### Dropped bindings

No herdr equivalent; intentionally left unbound rather than approximated:

| tmux | why |
|---|---|
| `,` / `.` swap-window | no move-tab action |
| `\` last session | only `previous_workspace`/`next_workspace` exist, both unset |
| `H/J/K/L` one-shot resize | herdr resizing is modal (`prefix+r`, then `h/j/k/l`) |

## Project picker

Replaces the sesh picker. One fzf list mixing open and closed projects, so
"jump to what I'm working on" and "open a project I'm not in yet" are the same
keystroke.

**List sources**

1. Open targets — `herdr workspace list` and `herdr tab list --workspace <id>`,
   labelled with a terminal-cyan nerd-font icon. Routing key is the workspace or
   tab ID.
2. Known-but-closed paths — `zoxide query -l`, labelled with a terminal-yellow
   bolt icon, shortened to the last two path segments. Routing key is the path.

Paths already open as a workspace are filtered out, so a project appears once.

**Preview** — a path previews as `eza --tree --level=2`; an open target previews
as `herdr pane read <pane-id> --source recent-unwrapped --lines 20` (the
`tmux capture-pane` analog).

**Selection routing** — mirrors the existing `route_selection` logic against
`sesh.toml` roots:

- Open target → `herdr workspace focus <id>` or `herdr tab focus <id>`.
- Path equal to a `sesh.toml` root → `herdr workspace create --cwd <path>
  --label <name> --focus`.
- Path *under* a root → reuse that root's workspace: find a tab whose cwd
  matches, `herdr tab focus` it; otherwise `herdr tab create --workspace <id>
  --cwd <path> --focus`. This preserves the current "one session per project
  root, one window per subdirectory" model.
- Path under no root → `herdr workspace create --cwd <path> --focus`.

**`ctrl-d`** closes the highlighted target (`herdr tab close` /
`herdr workspace close`) and reloads the list, matching the tmux binding.

Colors stay ANSI-named so the terminal palette continues to drive light/dark.

## Dual-backend scripts

`terminals/sesh/sesh-picker.sh` and `terminals/playzones/lib.sh` call
`tmux switch-client / list-windows / capture-pane / new-window / split-window /
send-keys` directly. Inside herdr these silently no-op.

Both get a backend switch on `HERDR_ENV=1`: herdr CLI when set, existing tmux
path otherwise. One copy of the picker/routing logic, two backends. tmux keeps
working throughout the transition.

`lib.sh` is the smaller job — five tmux call sites behind two functions:

| function | tmux | herdr |
|---|---|---|
| `pz_ensure_session` | `has-session` / `new-session -d` | `workspace list` → `workspace create` |
| `pz_open_or_split` | `list-windows` + `new-window` / `split-window` + `send-keys` | `tab list` + `tab create` / `pane split` + `pane run` |

`terminals/notes/note.sh` needs no change — it only `exec`s nvim. Its comment
about tmux not sourcing fish config applies equally to the herdr server, so the
`NOTES_DIR` fallback stays load-bearing; the comment gets updated to say so.

## Fish autostart

Appended to `terminals/fish/config.fish`:

```fish
# herdr is the outer multiplexer for interactive terminals. Guards: already
# inside a herdr pane, inside tmux, or remote (herdr --remote handles that).
if status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
    exec herdr
end
```

`exec` replaces the shell, so quitting herdr closes the window — the expected
behavior for an outer multiplexer, and it avoids a stray parent shell per window.
`HERDR_ENV=1` in panes prevents recursion.

Ghostty needs no change: it has no `command =` line, so it runs login fish, which
now reaches this block.

## File layout

- `terminals/herdr/config.toml` — absorbs the current `~/.config/herdr/config.toml`
  (onboarding, toast delivery, agent labels/sort), switches `[theme]` to
  `auto_switch`, and adds `[keys]` plus the `[[keys.command]]` blocks.
- `~/.config/herdr/config.toml` → symlink to the above, replacing the real file.
- `bootstrap/mac.sh` — `mkdir -p ~/.config/herdr` and the symlink, following the
  existing rio/nix `ln -s` pattern.

## Verification

1. `herdr config check` reports `config: ok` with **no** `invalid keybinding`
   warnings. Warnings disable bindings silently, so a clean run is the gate.
2. `herdr server reload-config`, then exercise by hand: prefix, both splits, tab
   prev/next, all ten launchers, both renames, pane swap.
3. `prefix+shift+t` flips macOS appearance and herdr's own colors follow it
   without a reload; `git status` on the dotfiles repo stays clean afterward.
4. Project picker: focus an open project, open a closed one from zoxide, open a
   subdirectory of a `sesh.toml` root (must reuse that workspace), `ctrl-d` close.
5. Playzone `ku-regask` opens `ku` in a split under the `LX-REGASK` workspace.
6. New Ghostty window lands in herdr; `echo $HERDR_ENV` is `1`; launching a
   nested fish inside a pane does not re-exec herdr.
7. Run the picker and a playzone from inside tmux to confirm the tmux backend
   still works.
