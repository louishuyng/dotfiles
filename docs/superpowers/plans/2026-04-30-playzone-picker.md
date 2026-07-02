# Playzone Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `prefix p` tmux binding that opens an fzf popup of "playzones" — named scripted actions that target a tmux session/window and run a command (creating or splitting the window as needed). First playzone: `k9s-regask-staging`.

**Architecture:** A new `terminals/playzones/` directory mirrors `terminals/sesh/` in shape. A TOML registry (`playzones.toml`) lists playzones with `name`, `description`, and a path to a script. The fzf popup parses the TOML, shows entries with descriptions, and execs the chosen script. Scripts source a shared `lib.sh` that exposes `pz_ensure_session` and `pz_open_or_split` so each playzone is ~3 lines.

**Tech Stack:** bash, tmux, fzf, sesh, regex-based TOML parsing (matches existing `sesh-picker.sh` style), optional `bat` for preview pane.

**Reference spec:** `docs/superpowers/specs/2026-04-30-playzone-picker-design.md`

**Verification approach:** No automated tests (per spec — bash/tmux interaction tests aren't worth the maintenance for a dotfiles component). Each task ends with a manual smoke check the engineer must run and confirm before moving on.

---

## File Structure

Files this plan creates or modifies:

- **Create** `terminals/playzones/lib.sh` — shared helpers (`pz_ensure_session`, `pz_open_or_split`).
- **Create** `terminals/playzones/scripts/k9s-regask-staging.sh` — first playzone script.
- **Create** `terminals/playzones/playzones.toml` — registry.
- **Create** `terminals/playzones/playzone-picker.sh` — fzf popup launched by tmux.
- **Modify** `terminals/tmux/.tmux.conf` — add `bind p display-popup ... playzone-picker.sh`.

All paths are relative to `/Users/louishuyng/.dotfiles/`.

---

### Task 1: Create `lib.sh` with shared helpers

**Files:**
- Create: `terminals/playzones/lib.sh`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p /Users/louishuyng/.dotfiles/terminals/playzones/scripts
```

- [ ] **Step 2: Write `lib.sh`**

Path: `terminals/playzones/lib.sh`

```bash
#!/opt/homebrew/bin/bash
# Shared helpers for playzone scripts.
# Source from a script via:
#   DIR="$(cd "$(dirname "$0")/.." && pwd)"
#   source "$DIR/lib.sh"

# pz_ensure_session <name>
#   Ensure a tmux session named <name> exists. If it doesn't, create it
#   via `sesh connect -d` so sesh.toml lookups still resolve roots.
pz_ensure_session() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "pz_ensure_session: missing session name" >&2
    return 2
  fi
  if tmux has-session -t "=$name" 2>/dev/null; then
    return 0
  fi
  sesh connect -d "$name"
}

# pz_open_or_split <session> <window> <split-flag> <split-size> <cmd>
#   If <session>:<window> does not exist:
#     - create the window with <cmd> as its starting command
#     - switch client to it
#   If it does exist:
#     - switch client to it
#     - split using <split-flag> at <split-size>
#     - send-keys "<cmd>" Enter into the new pane
#
#   <split-flag> is "-v" (split below) or "-h" (split right).
#   <split-size> is e.g. "30%".
pz_open_or_split() {
  local session="$1" window="$2" split_flag="$3" split_size="$4" cmd="$5"

  if [[ -z "$session" || -z "$window" || -z "$split_flag" || -z "$split_size" || -z "$cmd" ]]; then
    echo "pz_open_or_split: missing argument(s)" >&2
    return 2
  fi

  local target="$session:$window"

  if tmux list-windows -t "$session" -F '#W' 2>/dev/null | grep -Fxq "$window"; then
    tmux switch-client -t "$target"
    tmux split-window "$split_flag" -l "$split_size" -t "$target"
    tmux send-keys -t "$target" "$cmd" Enter
  else
    tmux new-window -t "$session" -n "$window" "$cmd"
    tmux switch-client -t "$target"
  fi
}
```

- [ ] **Step 3: Make it readable (no exec needed; it's sourced)**

```bash
chmod 0644 /Users/louishuyng/.dotfiles/terminals/playzones/lib.sh
```

- [ ] **Step 4: Smoke check the helpers in isolation**

Run from inside an existing tmux session:

```bash
bash -c 'source /Users/louishuyng/.dotfiles/terminals/playzones/lib.sh; pz_open_or_split "$(tmux display -p "#S")" "pz-smoke" "-v" "30%" "echo hello-from-playzone"'
```

Expected outcomes:
- A new window named `pz-smoke` is created in the current session running `echo hello-from-playzone` (which exits immediately, leaving a dead pane — that's fine).
- Run the same command again. Expected: client switches to the existing `pz-smoke` window, a new split appears below at 30%, and `echo hello-from-playzone` runs in the new pane.

After confirming, clean up:

```bash
tmux kill-window -t "pz-smoke"
```

- [ ] **Step 5: Commit**

```bash
git add terminals/playzones/lib.sh
git commit -m "feat(playzones): add lib.sh with pz_ensure_session and pz_open_or_split helpers"
```

---

### Task 2: Add the first playzone script `k9s-regask-staging.sh`

**Files:**
- Create: `terminals/playzones/scripts/k9s-regask-staging.sh`

- [ ] **Step 1: Write the script**

Path: `terminals/playzones/scripts/k9s-regask-staging.sh`

```bash
#!/opt/homebrew/bin/bash
# Playzone: k9s-regask-staging
# Open (or split) LX-REGASK:k9s-play running `regask-staging`.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib.sh"

pz_ensure_session "LX-REGASK"
pz_open_or_split "LX-REGASK" "k9s-play" "-v" "30%" "regask-staging"
```

- [ ] **Step 2: Make it executable**

```bash
chmod 0755 /Users/louishuyng/.dotfiles/terminals/playzones/scripts/k9s-regask-staging.sh
```

- [ ] **Step 3: Smoke check by invoking the script directly**

From inside any tmux client:

```bash
/Users/louishuyng/.dotfiles/terminals/playzones/scripts/k9s-regask-staging.sh
```

Expected on first run:
- Client switches to session `LX-REGASK` (sesh creates it if missing using `~/.config/sesh/sesh.toml`).
- A new window `k9s-play` is created. The window's starting command is `regask-staging`, so it runs immediately.

Expected on second run (with `LX-REGASK:k9s-play` already existing):
- Client switches to `LX-REGASK:k9s-play`.
- A new horizontal split (30%, below) appears.
- The new pane runs `regask-staging`.

If `regask-staging` is not on `$PATH` in the new pane, fish should still resolve it as a function (the new pane spawns fish, which loads its functions). If it doesn't, that's a fish-config issue, not a playzone issue — flag it but do not work around it.

Do not clean up the `k9s-play` window after this check — leave it for the picker test in Task 4.

- [ ] **Step 4: Commit**

```bash
git add terminals/playzones/scripts/k9s-regask-staging.sh
git commit -m "feat(playzones): add k9s-regask-staging playzone script"
```

---

### Task 3: Create the registry `playzones.toml`

**Files:**
- Create: `terminals/playzones/playzones.toml`

- [ ] **Step 1: Write the TOML**

Path: `terminals/playzones/playzones.toml`

```toml
# Playzone registry.
# Each [[playzone]] block describes a scripted action surfaced in the
# playzone picker (prefix p in tmux).
#
# Fields:
#   name        — unique identifier, primary label in the picker
#   description — secondary label shown next to the name
#   script      — path to the script, relative to this file's directory

[[playzone]]
name = "k9s-regask-staging"
description = "k9s pointed at regask-staging cluster"
script = "scripts/k9s-regask-staging.sh"
```

- [ ] **Step 2: Commit**

```bash
git add terminals/playzones/playzones.toml
git commit -m "feat(playzones): add playzones.toml registry with k9s-regask-staging entry"
```

---

### Task 4: Build `playzone-picker.sh`

**Files:**
- Create: `terminals/playzones/playzone-picker.sh`

- [ ] **Step 1: Write the picker**

Path: `terminals/playzones/playzone-picker.sh`

```bash
#!/opt/homebrew/bin/bash
# Playzone picker. Reads playzones.toml from this directory, lets the
# user choose one via fzf, and execs the selected script.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
TOML="$DIR/playzones.toml"

# Tokyo Night palette + nerd-font icon (matches sesh-picker.sh).
ICON_FG=$'\033[38;2;125;207;255m'   # #7dcfff cyan
RESET=$'\033[0m'
ICON=$''                          # nerd-font glyph (gamepad-ish)

#--------------------------------------------------------------------
# parse_toml <out>
#   Walk playzones.toml. For each [[playzone]] block, emit a single
#   tab-separated line: "<name>\t<description>\t<script-abs-path>".
#--------------------------------------------------------------------
parse_toml() {
  local out="$1"
  : > "$out"
  [[ -r "$TOML" ]] || return 0

  local name="" desc="" script="" line
  local in_block=0

  flush() {
    if [[ -n "$name" && -n "$script" ]]; then
      local abs="$script"
      [[ "$abs" != /* ]] && abs="$DIR/$abs"
      printf '%s\t%s\t%s\n' "$name" "$desc" "$abs" >> "$out"
    fi
    name=""; desc=""; script=""
  }

  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*\[\[playzone\]\][[:space:]]*$ ]]; then
      [[ $in_block -eq 1 ]] && flush
      in_block=1
      continue
    fi
    [[ $in_block -eq 1 ]] || continue
    if [[ "$line" =~ ^[[:space:]]*name[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*description[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      desc="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*script[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      script="${BASH_REMATCH[1]}"
    fi
  done < "$TOML"

  [[ $in_block -eq 1 ]] && flush
  return 0
}

#--------------------------------------------------------------------
# render <toml-rows> <out>
#   Convert parsed rows to fzf input:
#     col1: "<icon> <name>"  (display)
#     col2: "<description>"  (display)
#     col3: "<script-abs-path>" (hidden, used for routing)
#--------------------------------------------------------------------
render() {
  local in="$1" out="$2"
  : > "$out"
  local name desc script
  while IFS=$'\t' read -r name desc script; do
    [[ -z "$name" ]] && continue
    printf '%s%s%s %s\t%s\t%s\n' "$ICON_FG" "$ICON" "$RESET" "$name" "$desc" "$script" >> "$out"
  done < "$in"
}

#--------------------------------------------------------------------
# preview <script-path>
#--------------------------------------------------------------------
cmd_preview() {
  local script="${1:-}"
  [[ -z "$script" || ! -r "$script" ]] && { printf '(no preview)\n'; return 0; }
  if command -v bat >/dev/null 2>&1; then
    bat --color=always --style=plain --paging=never "$script"
  else
    cat "$script"
  fi
}

#--------------------------------------------------------------------
cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/playzone-picker.XXXXXX") || return 1
  trap 'rm -rf "$tmp"' EXIT

  parse_toml "$tmp/rows.tsv"
  render "$tmp/rows.tsv" "$tmp/list.tsv"

  if [[ ! -s "$tmp/list.tsv" ]]; then
    printf '(no playzones configured — edit %s)\n' "$TOML"
    sleep 2
    exit 0
  fi

  local selected
  local script="$0"
  selected=$(FZF_DEFAULT_OPTS= fzf \
    --ansi --no-sort --border none --padding 0 --margin 0 --info=hidden \
    --pointer '▌' --marker '▍' \
    --prompt '❯ ' \
    --delimiter=$'\t' --with-nth=1,2 --nth=1,2 \
    --color='fg:#c0caf5,bg:-1,fg+:#c0caf5,bg+:#364a82,hl:#7aa2f7,hl+:#bb9af7,pointer:#bb9af7,prompt:#7dcfff,marker:#9ece6a,gutter:-1' \
    --bind 'tab:down,btab:up' \
    --preview "bash $script --preview {3}" \
    --preview-window 'right:45%:wrap:border-left' \
    < "$tmp/list.tsv") || exit 0

  [[ -z "$selected" ]] && exit 0

  local script_path
  script_path=$(printf '%s' "$selected" | awk -F'\t' '{print $3}')
  [[ -z "$script_path" || ! -x "$script_path" ]] && {
    echo "playzone-picker: script not executable: $script_path" >&2
    exit 1
  }
  exec "$script_path"
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  *)         cmd_main ;;
esac
```

- [ ] **Step 2: Make it executable**

```bash
chmod 0755 /Users/louishuyng/.dotfiles/terminals/playzones/playzone-picker.sh
```

- [ ] **Step 3: Smoke check the picker outside tmux popup**

Run directly from a tmux pane:

```bash
/Users/louishuyng/.dotfiles/terminals/playzones/playzone-picker.sh
```

Expected:
- fzf opens inline showing one row: cyan icon + `k9s-regask-staging` + `k9s pointed at regask-staging cluster`.
- Right-side preview shows the contents of `scripts/k9s-regask-staging.sh`.
- Pressing Enter exits fzf and runs the script. Behavior should match Task 2's smoke check (creates window or splits + runs `regask-staging`).
- Pressing Esc exits with no action.

- [ ] **Step 4: Commit**

```bash
git add terminals/playzones/playzone-picker.sh
git commit -m "feat(playzones): add playzone-picker.sh fzf popup"
```

---

### Task 5: Wire up the tmux binding

**Files:**
- Modify: `terminals/tmux/.tmux.conf`

- [ ] **Step 1: Locate the sesh popup binding**

Open `terminals/tmux/.tmux.conf` and find the existing sesh binding:

```tmux
# sesh session manager
set -g popup-border-lines rounded
bind s display-popup -h 50% -w 60% -T ' sesh ' -E "~/.dotfiles/terminals/sesh/sesh-picker.sh"
```

- [ ] **Step 2: Add the playzone binding directly after the sesh binding**

Insert these two lines immediately after the `bind s ...` line:

```tmux

# playzone picker
bind p display-popup -h 50% -w 60% -T ' playzone ' -E "~/.dotfiles/terminals/playzones/playzone-picker.sh"
```

(Leading blank line keeps the file readable.)

- [ ] **Step 3: Reload tmux config**

From inside any tmux session:

```
prefix r
```

Expected: status line shows `Configuration Reloaded`.

- [ ] **Step 4: End-to-end smoke check**

Press `prefix p` (i.e. `C-a` then `p`).

Expected:
- A popup opens, 50% tall, 60% wide, titled ` playzone `, rendering the picker.
- Selecting `k9s-regask-staging` and pressing Enter closes the popup and runs the script. Result depends on whether `LX-REGASK:k9s-play` already exists:
  - **Absent:** new window created with `regask-staging` running.
  - **Present:** client switches to it, a 30% split below appears, `regask-staging` runs in the split.

If you accidentally bound `p` somewhere else later in the file, this binding will lose to whatever is later — check by running `tmux list-keys | grep -E '(\s|^)bind-key.*\sp\s'` after reload and confirming only one binding for `p` in the prefix table.

- [ ] **Step 5: Commit**

```bash
git add terminals/tmux/.tmux.conf
git commit -m "feat(tmux): bind prefix p to playzone picker"
```

---

## Self-review notes (already applied)

- All five spec components have a task: `lib.sh` (Task 1), playzone script (Task 2), `playzones.toml` (Task 3), `playzone-picker.sh` (Task 4), tmux binding (Task 5).
- Helper signatures used in Task 2's script (`pz_ensure_session`, `pz_open_or_split` with `-v 30%`) match exactly what Task 1 defines.
- The picker's TSV columns (col 3 = absolute script path) are consistent with the `--preview` and `awk '{print $3}'` use in Task 4.
- No placeholders, no "similar to above" hand-waves, no missing commands.
