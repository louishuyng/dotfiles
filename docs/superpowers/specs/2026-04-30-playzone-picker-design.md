# Playzone Picker — Design

**Date:** 2026-04-30
**Status:** Approved

## Goal

Bind a tmux key (`prefix p`) that opens an fzf popup listing
"playzones" — named, described actions that target a specific tmux
session/window and run a command, splitting the window if it already
exists.

The first playzone is `k9s-regask-staging`: open `LX-REGASK:k9s-play`
running `regask-staging`, splitting (horizontal, 30%) if the window is
already there.

## Non-goals

- Generic task runner. Playzones are tmux-aware and assume a
  session/window/command shape.
- Replacing sesh. Playzones complement sesh by jumping to specific
  windows inside sessions sesh already manages.
- A GUI / TUI beyond the fzf popup.

## Architecture

```
~/.dotfiles/terminals/playzones/
├── playzones.toml         # registry
├── playzone-picker.sh     # fzf popup, mirrors sesh-picker.sh
├── lib.sh                 # shared helpers
└── scripts/
    └── k9s-regask-staging.sh
```

Sourced from tmux via:

```tmux
bind p display-popup -h 50% -w 60% -T ' playzone ' \
    -E "~/.dotfiles/terminals/playzones/playzone-picker.sh"
```

`prefix p` opens the popup directly. `p` was previously unbound (the
config explicitly does `unbind p`), so no conflict.

## Components

### `playzones.toml` (registry)

```toml
[[playzone]]
name = "k9s-regask-staging"
description = "k9s pointed at regask-staging cluster"
script = "scripts/k9s-regask-staging.sh"
```

- `name` — unique identifier, primary label in the picker.
- `description` — secondary label shown next to the name.
- `script` — path relative to the `playzones/` directory.

Parsed with the same regex approach `sesh-picker.sh` uses (no extra
dep): walk lines, match `name = "…"`, `description = "…"`, `script =
"…"` into a tab-separated list.

### `lib.sh` (helpers)

Two functions exposed to scripts:

```bash
pz_ensure_session <name>
# Creates the sesh session in detached mode if it does not exist.
# Implementation: if `tmux has-session -t <name>` fails,
#                 run `sesh connect -d <name>` (sesh handles toml lookup).

pz_open_or_split <session> <window> <split-flag> <split-size> <cmd>
# 1. If <session>:<window> does NOT exist:
#      tmux new-window -t <session> -n <window> "<cmd>"
#      tmux switch-client -t <session>:<window>
# 2. If <session>:<window> DOES exist:
#      tmux switch-client -t <session>:<window>
#      tmux split-window <split-flag> -l <split-size> -t <session>:<window>
#      tmux send-keys -t <session>:<window> "<cmd>" Enter
#
# Window detection:
#   tmux list-windows -t <session> -F '#W' | grep -Fxq <window>
```

Notes:

- Window check is by name (`#W`), not pane path — playzones address
  windows by name.
- `split-flag` matches tmux semantics: `-v` (horizontal split, new pane
  below) or `-h` (vertical split, new pane right).
- The `send-keys` form runs the literal command in whatever shell the
  new pane spawns (fish, in our case), so fish functions like
  `regask-staging` resolve normally.

### `playzone-picker.sh`

Shape mirrors `sesh-picker.sh`:

1. Parse `playzones.toml` into a tab-separated list:
   `<name>\t<description>\t<script-path>`.
2. fzf popup:
   - `--ansi --no-sort --border none --padding 0 --margin 0 --info=hidden`
   - `--delimiter=$'\t' --with-nth=1,2 --nth=1,2`
   - Tokyo Night palette identical to sesh-picker.
   - Icon prefix on the name field (nerd-font glyph, cyan).
   - `--preview "bat --color=always <script-path>"` falling back to
     `cat`. Preview pane right 45%, border-left.
3. On selection: extract `<script-path>` from the chosen row, resolve
   it relative to the `playzones/` dir, exec it.

### `scripts/k9s-regask-staging.sh`

```bash
#!/opt/homebrew/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib.sh"

pz_ensure_session "LX-REGASK"
pz_open_or_split "LX-REGASK" "k9s-play" "-v" "30%" "regask-staging"
```

## Data flow

```
prefix p
   │
   ▼
tmux display-popup ──► playzone-picker.sh
                        │
                        ├─ parse playzones.toml
                        ├─ render fzf list (name + description)
                        └─ on enter: exec scripts/<name>.sh
                                       │
                                       ├─ source lib.sh
                                       ├─ pz_ensure_session LX-REGASK
                                       └─ pz_open_or_split LX-REGASK k9s-play -v 30% regask-staging
                                            │
                                            ├─ window absent ─► new-window + switch-client
                                            └─ window present ─► switch-client + split-window + send-keys
```

## Error handling

- **Missing TOML**: picker prints a single message row in fzf
  (`(no playzones configured — edit playzones.toml)`) and exits cleanly
  on selection.
- **Script not executable**: picker `chmod +x`'s the script before exec
  and warns once via stderr if that fails.
- **`tmux has-session` failure for a session not in `sesh.toml`**: `sesh
  connect` will return non-zero. The script aborts with `set -e`; user
  sees the error in the popup output. No silent fallback.
- **Empty selection / Esc**: picker exits 0, no action.

## Adding a new playzone

1. Drop a script under `scripts/<name>.sh`, mark it executable.
2. Add a `[[playzone]]` block to `playzones.toml`.
3. (Re)open the picker — the registry is read at every invocation.

No code changes to picker or lib are needed for the common
"open-window-or-split-and-run" pattern.

## Testing

- **Manual smoke**: from a fresh tmux server, `prefix p`, select
  `k9s-regask-staging` — expect a new `LX-REGASK:k9s-play` window with
  `regask-staging` running. Repeat — expect the same window, now with a
  30% split below also running `regask-staging`.
- **No automated tests.** Bash + tmux interaction tests aren't worth
  the maintenance overhead for a single-user dotfile component.

## Open questions

None. All decisions resolved during brainstorming.
