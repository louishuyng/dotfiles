# herdr Keybindings + tmux-Parity Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make herdr 0.8.0 the outer multiplexer with a keymap that mirrors the existing tmux config, all ten launchers on their current keys, a sesh-equivalent project picker, and fish autostart.

**Architecture:** herdr config moves into the dotfiles repo and is symlinked to `~/.config/herdr/config.toml`, following the existing rio pattern. The two tmux-coupled helper scripts (`sesh-picker.sh`, `playzones/lib.sh`) gain a herdr backend selected on `HERDR_ENV=1`, keeping their tmux paths intact. Shared herdr CLI primitives live in one sourced library so both scripts and the tests use the same seam.

**Tech Stack:** herdr 0.8.0 CLI (JSON over a unix socket), bash 5 (`/opt/homebrew/bin/bash`), `jq`, `fzf`, `zoxide`, `eza`, fish 3, bats.

**Spec:** `docs/superpowers/specs/2026-08-04-herdr-keybindings-design.md`

## Global Constraints

- herdr binary: `/Users/louishuyng/.local/bin/herdr`, version 0.8.0.
- Scripts use the shebang `#!/opt/homebrew/bin/bash` — matches every existing script in `terminals/`.
- All herdr CLI calls go through `$HERDR_BIN` (default `herdr`), never a bare `herdr`. This is the seam the bats tests replace with a fixture-emitting fake.
- Nesting guard is `HERDR_ENV=1`, set by herdr inside every pane.
- Key syntax is strict: `prefix+|` and `prefix+$` are valid; `prefix+pipe` and `prefix+dollar` are **not**. Invalid bindings are disabled with only a warning, never an error.
- `herdr config check` reads `$XDG_CONFIG_HOME/herdr/config.toml`. Use a temp `XDG_CONFIG_HOME` to validate without touching the live config.
- Colors in pickers stay ANSI-named (`\033[36m` cyan, `\033[33m` yellow) so the terminal palette drives light/dark.
- Never call `herdr workspace close` / `herdr tab close` during development against the live session without a target you created yourself.
- Commit after each task.

## File Structure

**Create:**
- `terminals/herdr/config.toml` — the whole herdr config: UI, theme, `[keys]`, `[[keys.command]]`.
- `terminals/herdr/lib.sh` — herdr CLI primitives (workspace/tab/pane lookup + create) shared by both pickers.
- `terminals/herdr/scripts/toggle-appearance.sh` — flips macOS dark mode; avoids TOML quoting of a nested-quote osascript.
- `terminals/sesh/roots.sh` — `parse_roots`, extracted from `sesh-picker.sh` so `playzones/lib.sh` can reuse it.
- `tests/herdr/lib.bats`, `tests/herdr/config.bats`, `tests/herdr/picker.bats` — bats coverage.
- `tests/herdr/fixtures/*.json` — captured herdr JSON responses.

**Modify:**
- `terminals/sesh/sesh-picker.sh` — dual backend.
- `terminals/playzones/lib.sh` — dual backend.
- `terminals/fish/config.fish:78` — append autostart block.
- `bootstrap/mac.sh` — symlink herdr config.
- `terminals/notes/note.sh:9-11` — comment now covers the herdr server too.

---

### Task 1: herdr config — native keymap, theme, symlink

**Files:**
- Create: `terminals/herdr/config.toml`
- Modify: `bootstrap/mac.sh` (after the rio block, ~line 195)
- Test: `tests/herdr/config.bats`

**Interfaces:**
- Consumes: nothing.
- Produces: `terminals/herdr/config.toml` symlinked at `~/.config/herdr/config.toml`. Task 2 appends `[[keys.command]]` blocks to the same file.

- [ ] **Step 1: Write the failing test**

Create `tests/herdr/config.bats`:

```bash
#!/usr/bin/env bats
# herdr disables invalid keybindings with only a warning, so "no warnings" is
# the real gate — `config: ok` alone would pass with every binding dead.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  XDG="$BATS_TEST_TMPDIR/xdg"
  mkdir -p "$XDG/herdr"
  cp "$REPO/terminals/herdr/config.toml" "$XDG/herdr/config.toml"
}

@test "config validates with no disabled bindings" {
  run env XDG_CONFIG_HOME="$XDG" herdr config check
  [ "$status" -eq 0 ]
  [[ "$output" == *"config: ok"* ]]
  [[ "$output" != *"invalid keybinding"* ]]
}

@test "prefix is ctrl+a" {
  grep -q '^prefix = "ctrl+a"$' "$XDG/herdr/config.toml"
}

@test "theme follows host appearance" {
  grep -q '^auto_switch = true$' "$XDG/herdr/config.toml"
}

@test "cycle_pane_next is cleared so last_pane can own prefix+tab" {
  grep -q '^cycle_pane_next = ""$' "$XDG/herdr/config.toml"
  grep -q '^last_pane = "prefix+tab"$' "$XDG/herdr/config.toml"
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/herdr/config.bats`
Expected: all 4 FAIL — `cp` errors in setup because `terminals/herdr/config.toml` does not exist.

- [ ] **Step 3: Write the config**

Create `terminals/herdr/config.toml`:

```toml
# Keybindings mirror terminals/tmux/.tmux.conf so muscle memory carries over.
# Design + rationale: docs/superpowers/specs/2026-08-04-herdr-keybindings-design.md

onboarding = false

[ui.toast]
delivery = "herdr"

[ui]
show_agent_labels_on_pane_borders = false
agent_panel_sort = "priority"

[theme]
# Tracks host light/dark so the com.user.theme-watcher launchd daemon stays the
# single source of truth for appearance.
auto_switch = true
dark_name = "catppuccin"
light_name = "catppuccin-latte"

[keys]
prefix = "ctrl+a"

# tmux parity. Anything absent here already matches tmux at herdr's default:
# h/j/k/l pane focus, prefix+- split below, z zoom, x close pane, c new tab,
# 1..9 switch tab, ? help, b sidebar, w workspace picker, shift+x close tab.
split_vertical = "prefix+|"
previous_tab = "prefix+ctrl+h"
next_tab = "prefix+ctrl+l"
detach = "prefix+d"
new_workspace = "prefix+ctrl+c"
rename_tab = "prefix+,"
rename_workspace = "prefix+$"

# Opens scrollback in nvim — a superset of the tmux v/y copy-mode flow.
edit_scrollback = "prefix+v"

# last-pane, not last-window: herdr has no last-tab action. cycle_pane_next is
# cleared to free the key; h/j/k/l already covers directional movement.
last_pane = "prefix+tab"
cycle_pane_next = ""

# Displaced by the bindings above and the launchers in [[keys.command]].
settings = "prefix+shift+s"       # prefix+s -> project picker
goto = "prefix+ctrl+g"            # prefix+g -> gh dash
reload_config = "prefix+ctrl+shift+r"  # prefix+shift+r -> serpl

switch_workspace = "prefix+shift+1..9"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bats tests/herdr/config.bats`
Expected: 4 PASS.

- [ ] **Step 5: Symlink, replacing the real file**

```bash
cp ~/.config/herdr/config.toml /tmp/herdr-config.bak
ln -sfn ~/.dotfiles/terminals/herdr/config.toml ~/.config/herdr/config.toml
ls -l ~/.config/herdr/config.toml
herdr config check
```

Expected: symlink points into `.dotfiles`; `config: ok` with no warnings.

- [ ] **Step 6: Add the bootstrap hook**

In `bootstrap/mac.sh`, immediately after the rio `ln -s` block, add:

```bash
  mkdir -p ~/.config/herdr
  ln -sfn ~/.dotfiles/terminals/herdr/config.toml ~/.config/herdr/config.toml
```

- [ ] **Step 7: Commit**

```bash
git add terminals/herdr/config.toml tests/herdr/config.bats bootstrap/mac.sh
git commit -m "feat(herdr): tmux-parity keymap and dotfiles-managed config"
```

---

### Task 2: Launchers, pane swap, theme toggle

**Files:**
- Modify: `terminals/herdr/config.toml` (append)
- Create: `terminals/herdr/scripts/toggle-appearance.sh`
- Test: `tests/herdr/config.bats` (extend)

**Interfaces:**
- Consumes: `terminals/herdr/config.toml` from Task 1.
- Produces: `prefix+s` invokes `terminals/sesh/sesh-picker.sh`, `prefix+p` invokes `terminals/playzones/playzone-picker.sh`. Tasks 4-6 make those work under herdr.

- [ ] **Step 1: Write the failing test**

Append to `tests/herdr/config.bats`:

```bash
@test "all ten launchers are bound" {
  for k in 'prefix+/' 'prefix+i' 'prefix+t' 'prefix+shift+r' 'prefix+a' \
           'prefix+ctrl+r' 'prefix+g' 'prefix+n' 'prefix+p' 'prefix+s'; do
    grep -qF "key = \"$k\"" "$XDG/herdr/config.toml" || {
      echo "missing launcher: $k"; return 1
    }
  done
}

@test "pane swap is bound on all four arrows" {
  for d in left right up down; do
    grep -qF "herdr pane swap --current --direction $d" "$XDG/herdr/config.toml" || {
      echo "missing swap: $d"; return 1
    }
  done
}

@test "theme toggle runs the appearance script, not a config rewrite" {
  grep -qF 'toggle-appearance.sh' "$XDG/herdr/config.toml"
  [ -x "$REPO/terminals/herdr/scripts/toggle-appearance.sh" ]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/herdr/config.bats`
Expected: the 3 new tests FAIL (first missing launcher `prefix+/`); the 4 from Task 1 still PASS.

- [ ] **Step 3: Write the appearance toggle script**

Create `terminals/herdr/scripts/toggle-appearance.sh`:

```bash
#!/opt/homebrew/bin/bash
# Flip macOS dark mode. herdr follows via theme.auto_switch, and tmux/nvim/ghostty
# via the com.user.theme-watcher launchd daemon — so this one key moves everything.
# Lives in a script rather than inline TOML to avoid nesting quotes in osascript.

set -euo pipefail

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
```

Then `chmod +x terminals/herdr/scripts/toggle-appearance.sh`.

- [ ] **Step 4: Append the command bindings**

Append to `terminals/herdr/config.toml`:

```toml
# ── Launchers ────────────────────────────────────────────────────────────────
# Keys match the tmux bindings they replace. gh dash and the note script were
# full tmux windows because nested TUIs needed room; herdr popups are
# session-modal, so 90% is enough and no tab is consumed.

[[keys.command]]
key = "prefix+/"
type = "popup"
command = "yazi"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+i"
type = "popup"
command = "lazydocker"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+t"
type = "popup"
command = "tuxedo"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+shift+r"
type = "popup"
command = "serpl"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+a"
type = "popup"
command = "posting"
width = "90%"
height = "90%"

[[keys.command]]
key = "prefix+ctrl+r"
type = "popup"
command = "tuicr"
width = "90%"
height = "90%"

[[keys.command]]
key = "prefix+g"
type = "popup"
command = "gh dash"
width = "90%"
height = "90%"

[[keys.command]]
key = "prefix+n"
type = "popup"
command = "~/.dotfiles/terminals/notes/note.sh"
width = "90%"
height = "90%"

[[keys.command]]
key = "prefix+p"
type = "popup"
command = "~/.dotfiles/terminals/playzones/playzone-picker.sh"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+s"
type = "popup"
command = "~/.dotfiles/terminals/sesh/sesh-picker.sh"
width = "80%"
height = "80%"

# ── Directional pane swap ────────────────────────────────────────────────────
# Mirrors the tmux arrow bindings. At an edge herdr returns
# reason:"no_neighbor" and exits 0, so this no-ops instead of erroring — unlike
# the tmux version, which fell back to swapping with the prev/next pane.

[[keys.command]]
key = "prefix+left"
type = "shell"
command = "herdr pane swap --current --direction left"

[[keys.command]]
key = "prefix+down"
type = "shell"
command = "herdr pane swap --current --direction down"

[[keys.command]]
key = "prefix+up"
type = "shell"
command = "herdr pane swap --current --direction up"

[[keys.command]]
key = "prefix+right"
type = "shell"
command = "herdr pane swap --current --direction right"

# ── Theme ────────────────────────────────────────────────────────────────────
# tmux bound T to a tmux-only theme swap. This flips macOS appearance instead,
# which herdr follows via theme.auto_switch — no config rewrite, so the
# dotfiles repo stays clean. prefix+shift+t is free because rename_tab moved
# to prefix+, (stock tmux rename-window).

[[keys.command]]
key = "prefix+shift+t"
type = "shell"
command = "~/.dotfiles/terminals/herdr/scripts/toggle-appearance.sh"
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bats tests/herdr/config.bats`
Expected: 7 PASS.

- [ ] **Step 6: Verify against the live server**

```bash
herdr server reload-config
```

Expected: no `invalid keybinding` output. Then press `ctrl+a shift+t` in herdr and confirm macOS appearance flips and herdr recolors without a further reload, and `git -C ~/.dotfiles status --short` stays clean.

- [ ] **Step 7: Commit**

```bash
git add terminals/herdr/config.toml terminals/herdr/scripts/toggle-appearance.sh tests/herdr/config.bats
git commit -m "feat(herdr): launchers, directional pane swap, appearance toggle"
```

---

### Task 3: Fish autostart

**Files:**
- Modify: `terminals/fish/config.fish` (append after line 78)
- Test: `tests/herdr/autostart.bats`

**Interfaces:**
- Consumes: nothing.
- Produces: `HERDR_ENV`/`TMUX`/`SSH_TTY` guard semantics relied on by Tasks 4-6.

- [ ] **Step 1: Write the failing test**

Create `tests/herdr/autostart.bats`:

```bash
#!/usr/bin/env bats
# Verifies the guard predicate directly. Running the real block would exec
# herdr and take over the test runner, so the condition is evaluated alone.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  COND='status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY'
}

@test "config.fish contains the guarded autostart" {
  grep -qF 'not set -q HERDR_ENV' "$REPO/terminals/fish/config.fish"
  grep -qF 'exec herdr' "$REPO/terminals/fish/config.fish"
}

@test "guard blocks inside a herdr pane" {
  run fish -c "set -gx HERDR_ENV 1; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks inside tmux" {
  run fish -c "set -gx TMUX /tmp/fake; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks over ssh" {
  run fish -c "set -gx SSH_TTY /dev/ttys999; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks in a non-interactive shell" {
  run fish -c "if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/herdr/autostart.bats`
Expected: test 1 FAILs (no autostart in `config.fish`). Tests 2-5 PASS already — they exercise fish's own predicate, and confirm the guard logic is sound before it is wired in.

- [ ] **Step 3: Append the autostart block**

Append to `terminals/fish/config.fish`:

```fish
# herdr is the outer multiplexer for interactive terminals. Guards: already
# inside a herdr pane, inside tmux, or remote (herdr --remote handles that).
# exec, so quitting herdr closes the window instead of leaving a parent shell.
if status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
    exec herdr
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bats tests/herdr/autostart.bats`
Expected: 5 PASS.

- [ ] **Step 5: Verify in a real window**

Open a new Ghostty window. Expected: it lands in herdr. Inside a pane, `echo $HERDR_ENV` prints `1`, and running `fish` there returns a plain shell rather than a nested herdr.

- [ ] **Step 6: Commit**

```bash
git add terminals/fish/config.fish tests/herdr/autostart.bats
git commit -m "feat(fish): launch herdr for interactive terminals"
```

---

### Task 4: herdr CLI primitives library

**Files:**
- Create: `terminals/herdr/lib.sh`
- Test: `tests/herdr/lib.bats`, `tests/herdr/fixtures/workspaces.json`, `tests/herdr/fixtures/panes.json`

**Interfaces:**
- Consumes: nothing.
- Produces — sourced by Tasks 5 and 6:
  - `hd_active()` → exit 0 iff `HERDR_ENV=1`
  - `hd_workspace_id_by_label <label>` → prints `workspace_id` or nothing
  - `hd_ensure_workspace <label> <cwd>` → prints `workspace_id`, creating+focusing if absent
  - `hd_tab_id_by_cwd <workspace_id> <cwd>` → prints `tab_id` or nothing
  - `hd_first_pane_id <tab_id>` → prints `pane_id` or nothing
  - `hd_open_tab <workspace_id> <cwd>` → prints `tab_id`, focused
  - `hd_split_run <pane_id> <direction> <ratio> <cwd> <cmd>` → splits, runs `cmd`; prints new `pane_id`
  - All read `$HERDR_BIN` (default `herdr`) — the test seam.

- [ ] **Step 1: Capture fixtures**

```bash
mkdir -p tests/herdr/fixtures
herdr workspace list > tests/herdr/fixtures/workspaces.json
herdr pane list --workspace "$(jq -r '.result.workspaces[0].workspace_id' tests/herdr/fixtures/workspaces.json)" \
  > tests/herdr/fixtures/panes.json
jq -c '.result.panes[0]|{pane_id,tab_id,cwd}' tests/herdr/fixtures/panes.json
```

Expected: prints something like `{"pane_id":"w8:p1","tab_id":"w8:t1","cwd":"/Users/louishuyng/.dotfiles"}`. `tab list` has no `cwd`, which is why pane data is the lookup path for cwd→tab.

- [ ] **Step 2: Write the failing test**

Create `tests/herdr/lib.bats`:

```bash
#!/usr/bin/env bats
# HERDR_BIN is swapped for a fake that replays fixtures, so these run with no
# herdr server and mutate nothing.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  FIX="$BATS_TEST_DIRNAME/fixtures"
  WS_ID="$(jq -r '.result.workspaces[0].workspace_id' "$FIX/workspaces.json")"
  WS_LABEL="$(jq -r '.result.workspaces[0].label' "$FIX/workspaces.json")"
  PANE_CWD="$(jq -r '.result.panes[0].cwd' "$FIX/panes.json")"
  TAB_ID="$(jq -r '.result.panes[0].tab_id' "$FIX/panes.json")"
  PANE_ID="$(jq -r '.result.panes[0].pane_id' "$FIX/panes.json")"

  # Fake herdr: replay fixtures for reads, log mutations to $CALLS.
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$CALLS"
case "\$1 \$2" in
  "workspace list") cat "$FIX/workspaces.json" ;;
  "pane list")      cat "$FIX/panes.json" ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wNEW"},"tab":{"tab_id":"wNEW:t1"},"root_pane":{"pane_id":"wNEW:p1"}}}' ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"wNEW:t9"},"root_pane":{"pane_id":"wNEW:p9"}}}' ;;
  "pane split")     echo '{"result":{"pane":{"pane_id":"wNEW:p10"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr"
  source "$REPO/terminals/herdr/lib.sh"
}

@test "hd_active follows HERDR_ENV" {
  HERDR_ENV=1 run hd_active
  [ "$status" -eq 0 ]
  run env -u HERDR_ENV hd_active
  [ "$status" -ne 0 ]
}

@test "hd_workspace_id_by_label finds an existing workspace" {
  run hd_workspace_id_by_label "$WS_LABEL"
  [ "$output" = "$WS_ID" ]
}

@test "hd_workspace_id_by_label prints nothing for an unknown label" {
  run hd_workspace_id_by_label "nope-does-not-exist"
  [ -z "$output" ]
}

@test "hd_ensure_workspace reuses rather than creates" {
  run hd_ensure_workspace "$WS_LABEL" "/tmp"
  [ "$output" = "$WS_ID" ]
  run grep -c "workspace create" "$CALLS"
  [ "$output" = "0" ]
}

@test "hd_ensure_workspace creates when absent" {
  run hd_ensure_workspace "brand-new" "/tmp/brand-new"
  [ "$output" = "wNEW" ]
  grep -q "workspace create --label brand-new --cwd /tmp/brand-new --focus" "$CALLS"
}

@test "hd_tab_id_by_cwd matches a pane cwd" {
  run hd_tab_id_by_cwd "$WS_ID" "$PANE_CWD"
  [ "$output" = "$TAB_ID" ]
}

@test "hd_tab_id_by_cwd prints nothing for an unmatched path" {
  run hd_tab_id_by_cwd "$WS_ID" "/definitely/not/open"
  [ -z "$output" ]
}

@test "hd_first_pane_id resolves a tab to its pane" {
  run hd_first_pane_id "$TAB_ID"
  [ "$output" = "$PANE_ID" ]
}

@test "hd_open_tab creates a focused tab" {
  run hd_open_tab "$WS_ID" "/tmp/x"
  [ "$output" = "wNEW:t9" ]
  grep -q "tab create --workspace $WS_ID --cwd /tmp/x --focus" "$CALLS"
}

@test "hd_split_run splits then runs the command in the new pane" {
  run hd_split_run "$PANE_ID" down 0.30 /tmp/x "ku"
  [ "$output" = "wNEW:p10" ]
  grep -q "pane split --pane $PANE_ID --direction down --ratio 0.30 --cwd /tmp/x" "$CALLS"
  grep -q "pane run wNEW:p10 ku" "$CALLS"
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bats tests/herdr/lib.bats`
Expected: all FAIL — `source` errors, `terminals/herdr/lib.sh` does not exist.

- [ ] **Step 4: Write the library**

Create `terminals/herdr/lib.sh`:

```bash
#!/opt/homebrew/bin/bash
# herdr CLI primitives shared by the project picker and the playzone helpers.
# Every call goes through $HERDR_BIN so tests can swap in a fixture replayer.
#
# herdr's `tab list` carries no cwd, so every cwd -> tab lookup goes through
# `pane list`, which exposes cwd and tab_id per pane.

HERDR_BIN="${HERDR_BIN:-herdr}"

# hd_active
#   True inside a herdr pane. The backend switch for dual-backend scripts.
hd_active() {
  [[ "${HERDR_ENV:-}" == "1" ]]
}

# hd_workspace_id_by_label <label>
hd_workspace_id_by_label() {
  local label="$1"
  [[ -z "$label" ]] && return 0
  "$HERDR_BIN" workspace list 2>/dev/null \
    | jq -r --arg l "$label" \
        'first(.result.workspaces[]? | select(.label == $l) | .workspace_id) // empty'
}

# hd_ensure_workspace <label> <cwd>
#   Print the id of the workspace named <label>, creating it rooted at <cwd>
#   if it does not exist.
hd_ensure_workspace() {
  local label="$1" cwd="$2"
  if [[ -z "$label" || -z "$cwd" ]]; then
    echo "hd_ensure_workspace: missing argument(s)" >&2
    return 2
  fi

  local id
  id=$(hd_workspace_id_by_label "$label")
  if [[ -n "$id" ]]; then
    printf '%s\n' "$id"
    return 0
  fi

  local expanded="${cwd/#\~/$HOME}"
  [[ -d "$expanded" ]] || mkdir -p "$expanded"

  "$HERDR_BIN" workspace create --label "$label" --cwd "$expanded" --focus 2>/dev/null \
    | jq -r '.result.workspace.workspace_id // empty'
}

# hd_tab_id_by_cwd <workspace_id> <cwd>
#   Print the id of the first tab in <workspace_id> holding a pane rooted at
#   <cwd>. Matches cwd, not foreground_cwd: the pane's root is stable, whereas
#   foreground_cwd drifts as the user cds around.
hd_tab_id_by_cwd() {
  local ws="$1" cwd="$2"
  [[ -z "$ws" || -z "$cwd" ]] && return 0
  local expanded="${cwd/#\~/$HOME}"
  "$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null \
    | jq -r --arg c "$expanded" \
        'first(.result.panes[]? | select(.cwd == $c) | .tab_id) // empty'
}

# hd_first_pane_id <tab_id>
hd_first_pane_id() {
  local tab="$1"
  [[ -z "$tab" ]] && return 0
  local ws="${tab%%:*}"
  "$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null \
    | jq -r --arg t "$tab" \
        'first(.result.panes[]? | select(.tab_id == $t) | .pane_id) // empty'
}

# hd_open_tab <workspace_id> <cwd>
hd_open_tab() {
  local ws="$1" cwd="$2"
  if [[ -z "$ws" || -z "$cwd" ]]; then
    echo "hd_open_tab: missing argument(s)" >&2
    return 2
  fi
  local expanded="${cwd/#\~/$HOME}"
  [[ -d "$expanded" ]] || mkdir -p "$expanded"
  "$HERDR_BIN" tab create --workspace "$ws" --cwd "$expanded" --focus 2>/dev/null \
    | jq -r '.result.tab.tab_id // empty'
}

# hd_split_run <pane_id> <direction> <ratio> <cwd> <cmd>
#   <direction> is "down" or "right"; <ratio> is a float such as 0.30.
hd_split_run() {
  local pane="$1" direction="$2" ratio="$3" cwd="$4" cmd="$5"
  if [[ -z "$pane" || -z "$direction" || -z "$ratio" || -z "$cwd" || -z "$cmd" ]]; then
    echo "hd_split_run: missing argument(s)" >&2
    return 2
  fi
  local expanded="${cwd/#\~/$HOME}"
  local new
  new=$("$HERDR_BIN" pane split --pane "$pane" --direction "$direction" \
          --ratio "$ratio" --cwd "$expanded" 2>/dev/null \
        | jq -r '.result.pane.pane_id // empty')
  [[ -z "$new" ]] && return 1
  "$HERDR_BIN" pane run "$new" "$cmd" >/dev/null 2>&1
  printf '%s\n' "$new"
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bats tests/herdr/lib.bats`
Expected: 10 PASS.

- [ ] **Step 6: Commit**

```bash
git add terminals/herdr/lib.sh tests/herdr/lib.bats tests/herdr/fixtures
git commit -m "feat(herdr): CLI primitives library with fixture-backed tests"
```

---

### Task 5: Playzone dual backend

**Files:**
- Create: `terminals/sesh/roots.sh`
- Modify: `terminals/playzones/lib.sh`, `terminals/sesh/sesh-picker.sh:9-30`
- Test: `tests/herdr/playzone.bats`

**Interfaces:**
- Consumes: `hd_active`, `hd_ensure_workspace`, `hd_tab_id_by_cwd`, `hd_first_pane_id`, `hd_open_tab`, `hd_split_run` from Task 4.
- Produces: `parse_roots <out-file>` in `terminals/sesh/roots.sh`, writing `<name>\t<abs-path>` lines. Task 6 consumes it.

- [ ] **Step 1: Write the failing test**

Create `tests/herdr/playzone.bats`:

```bash
#!/usr/bin/env bats

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  source "$REPO/terminals/sesh/roots.sh"
}

@test "parse_roots extracts named roots from sesh.toml" {
  SESH_TOML="$REPO/terminals/sesh/sesh.toml"
  parse_roots "$BATS_TEST_TMPDIR/roots.tsv"
  # Lower bound, not an exact count: this tests the parser, not the project
  # list, so adding a sesh entry must not fail the suite.
  run wc -l < "$BATS_TEST_TMPDIR/roots.tsv"
  [ "$output" -ge 4 ]
  # Tilde expansion and the name->path pairing are what actually matter.
  grep -qF "LX-REGASK	$HOME/LX14/repository/github.com/regask" "$BATS_TEST_TMPDIR/roots.tsv"
}

@test "parse_roots handles a synthetic toml exactly" {
  cat > "$BATS_TEST_TMPDIR/sesh.toml" <<'EOF'
[[session]]
name = "alpha"
path = "~/alpha"

[[session]]
name = "beta"
path = "/abs/beta"
EOF
  SESH_TOML="$BATS_TEST_TMPDIR/sesh.toml" parse_roots "$BATS_TEST_TMPDIR/s.tsv"
  run cat "$BATS_TEST_TMPDIR/s.tsv"
  [ "${lines[0]}" = "alpha	$HOME/alpha" ]
  [ "${lines[1]}" = "beta	/abs/beta" ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "playzone lib routes to herdr when HERDR_ENV=1" {
  CALLS="$BATS_TEST_TMPDIR/calls"; : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$CALLS"
case "\$1 \$2" in
  "workspace list") echo '{"result":{"workspaces":[]}}' ;;
  "pane list")      echo '{"result":{"panes":[]}}' ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wZ"},"tab":{"tab_id":"wZ:t1"},"root_pane":{"pane_id":"wZ:p1"}}}' ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"wZ:t2"},"root_pane":{"pane_id":"wZ:p2"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"

  run env HERDR_ENV=1 HERDR_BIN="$BATS_TEST_TMPDIR/herdr" \
      SESH_TOML="$REPO/terminals/sesh/sesh.toml" \
      bash -c "source '$REPO/terminals/playzones/lib.sh'; pz_ensure_session LX-REGASK"
  [ "$status" -eq 0 ]
  grep -q "workspace create --label LX-REGASK" "$CALLS"
  ! grep -q "tmux" "$CALLS"
}

@test "playzone lib does not call herdr outside a herdr pane" {
  CALLS="$BATS_TEST_TMPDIR/calls2"; : > "$CALLS"
  printf '#!/opt/homebrew/bin/bash\necho "$*" >> "%s"\n' "$CALLS" > "$BATS_TEST_TMPDIR/herdr"
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  run env -u HERDR_ENV HERDR_BIN="$BATS_TEST_TMPDIR/herdr" PATH="/usr/bin:/bin" \
      bash -c "source '$REPO/terminals/playzones/lib.sh'; pz_ensure_session LX-REGASK 2>/dev/null || true"
  [ ! -s "$CALLS" ]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/herdr/playzone.bats`
Expected: all 4 FAIL — `terminals/sesh/roots.sh` does not exist.

- [ ] **Step 3: Extract the roots parser**

Create `terminals/sesh/roots.sh`:

```bash
#!/opt/homebrew/bin/bash
# sesh.toml root parsing, shared by the project picker and the playzone helpers.

SESH_TOML="${SESH_TOML:-$HOME/.config/sesh/sesh.toml}"

# parse_roots <out>
#   Write one "<name>\t<abs-path>" line per [[session]] block to <out>.
parse_roots() {
  local out="$1"
  : > "$out"
  [[ -r "$SESH_TOML" ]] || return 0

  local current_name="" line
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*name[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*path[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]] && [[ -n "$current_name" ]]; then
      local p="${BASH_REMATCH[1]/#\~/$HOME}"
      printf '%s\t%s\n' "$current_name" "$p" >> "$out"
      current_name=""
    fi
  done < "$SESH_TOML"
}

# sesh_root_for <name>
#   Print the path registered for <name>, or nothing.
sesh_root_for() {
  local name="$1" tmp
  [[ -z "$name" ]] && return 0
  tmp=$(mktemp) || return 1
  parse_roots "$tmp"
  awk -F'\t' -v n="$name" '$1 == n {print $2; exit}' "$tmp"
  rm -f "$tmp"
}
```

In `terminals/sesh/sesh-picker.sh`, delete the local `SESH_TOML=` line and the whole `parse_roots()` definition (lines 4 and 12-30), and source the shared copy instead — immediately after the `SCRIPT=` assignment:

```bash
source "$(dirname "$SCRIPT")/roots.sh"
```

- [ ] **Step 4: Add the herdr backend to the playzone lib**

Rewrite `terminals/playzones/lib.sh`:

```bash
#!/opt/homebrew/bin/bash
# Shared helpers for playzone scripts.
# Source from a script via:
#   DIR="$(cd "$(dirname "$0")/.." && pwd)"
#   source "$DIR/lib.sh"
#
# Dual backend: herdr inside a herdr pane (HERDR_ENV=1), tmux otherwise. The
# tmux path is unchanged, so playzones keep working during the migration.

_PZ_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_PZ_DIR/../herdr/lib.sh"
source "$_PZ_DIR/../sesh/roots.sh"

# pz_ensure_session <name>
#   herdr: ensure a workspace labelled <name> exists, rooted at its sesh.toml path.
#   tmux:  ensure a session named <name> exists, via `sesh connect` (sesh reads
#          sesh.toml for root/cmd and auto-switches the client when $TMUX is set).
pz_ensure_session() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "pz_ensure_session: missing session name" >&2
    return 2
  fi

  if hd_active; then
    local root
    root=$(sesh_root_for "$name")
    if [[ -z "$root" ]]; then
      echo "pz_ensure_session: no sesh.toml root for '$name'" >&2
      return 2
    fi
    hd_ensure_workspace "$name" "$root" >/dev/null
    return $?
  fi

  if tmux has-session -t "=$name" 2>/dev/null; then
    return 0
  fi
  sesh connect "$name"
}

# pz_open_or_split <session> <cmd> <cwd> <split-flag> <split-size>
#   Locate (or create) a tab/window in <session> rooted at <cwd>.
#
#   Not present: create it with <cwd> as its starting directory and <cmd> as
#   its starting command, then focus it.
#   Present: focus it, split at <split-size>, and run <cmd> in the new pane.
#
#   <split-flag> is "-v" (below) or "-h" (right); <split-size> is e.g. "30%".
#   Both are tmux spellings, translated for herdr: -v -> down, -h -> right,
#   and the percentage becomes a 0..1 ratio.
pz_open_or_split() {
  local session="$1" cmd="$2" cwd="$3" split_flag="$4" split_size="$5"

  if [[ -z "$session" || -z "$cmd" || -z "$cwd" || -z "$split_flag" || -z "$split_size" ]]; then
    echo "pz_open_or_split: missing argument(s)" >&2
    return 2
  fi

  local expanded_cwd="${cwd/#\~/$HOME}"
  [[ -d "$expanded_cwd" ]] || mkdir -p "$expanded_cwd"

  if hd_active; then
    local ws tab direction ratio pane
    ws=$(hd_workspace_id_by_label "$session")
    if [[ -z "$ws" ]]; then
      echo "pz_open_or_split: no workspace '$session' — call pz_ensure_session first" >&2
      return 1
    fi

    case "$split_flag" in
      -v) direction="down" ;;
      -h) direction="right" ;;
      *)  echo "pz_open_or_split: bad split flag '$split_flag'" >&2; return 2 ;;
    esac
    ratio=$(awk -v s="${split_size%\%}" 'BEGIN { printf "%.2f", s / 100 }')

    tab=$(hd_tab_id_by_cwd "$ws" "$expanded_cwd")
    if [[ -n "$tab" ]]; then
      "${HERDR_BIN:-herdr}" tab focus "$tab" >/dev/null 2>&1
      pane=$(hd_first_pane_id "$tab")
      hd_split_run "$pane" "$direction" "$ratio" "$expanded_cwd" "$cmd" >/dev/null
    else
      tab=$(hd_open_tab "$ws" "$expanded_cwd")
      pane=$(hd_first_pane_id "$tab")
      "${HERDR_BIN:-herdr}" pane run "$pane" "$cmd" >/dev/null 2>&1
    fi
    return 0
  fi

  local existing_idx
  existing_idx=$(tmux list-windows -t "$session" -F '#{window_index} #{pane_current_path}' 2>/dev/null \
    | awk -v p="$expanded_cwd" '$2 == p {print $1; exit}')

  if [[ -n "$existing_idx" ]]; then
    local target="$session:$existing_idx"
    tmux switch-client -t "$target"
    tmux split-window "$split_flag" -l "$split_size" -t "$target" -c "$expanded_cwd"
    tmux send-keys -t "$target" "$cmd" Enter
  else
    tmux new-window -t "$session" -c "$expanded_cwd" "$cmd"
    tmux switch-client -t "$session"
  fi
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bats tests/herdr/playzone.bats tests/herdr/lib.bats`
Expected: 14 PASS. The sesh-picker edit is covered by Task 6's tests; confirm it still parses now with `bash -n terminals/sesh/sesh-picker.sh`.

- [ ] **Step 6: Verify live**

Inside herdr press `ctrl+a p`, pick `ku-regask`. Expected: an `LX-REGASK` workspace exists (created if needed) with a tab rooted at `~/LX14/repository/github.com/regask/k9s-play` running `ku`; pressing it again splits below at 30% and runs `ku` in the new pane.

- [ ] **Step 7: Commit**

```bash
git add terminals/sesh/roots.sh terminals/playzones/lib.sh terminals/sesh/sesh-picker.sh tests/herdr/playzone.bats
git commit -m "feat(playzones): herdr backend alongside tmux, shared sesh root parsing"
```

---

### Task 6: Project picker herdr backend

**Files:**
- Modify: `terminals/sesh/sesh-picker.sh`
- Test: `tests/herdr/picker.bats`

**Interfaces:**
- Consumes: everything from Task 4, plus `parse_roots` / `sesh_root_for` from Task 5.
- Produces: `sesh-picker.sh --list` prints the assembled fzf list without launching fzf — the seam the tests use.

- [ ] **Step 1: Write the failing test**

Create `tests/herdr/picker.bats`:

```bash
#!/usr/bin/env bats
# --list prints the assembled list without launching fzf, so the list-building
# and dedup logic is testable non-interactively.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  PICKER="$REPO/terminals/sesh/sesh-picker.sh"
  FIX="$BATS_TEST_TMPDIR"

  cat > "$FIX/ws.json" <<'EOF'
{"result":{"workspaces":[{"workspace_id":"w1","label":"LX-REGASK","tab_count":2}]}}
EOF
  cat > "$FIX/panes.json" <<'EOF'
{"result":{"panes":[
 {"pane_id":"w1:p1","tab_id":"w1:t1","cwd":"/Users/x/regask/api"},
 {"pane_id":"w1:p2","tab_id":"w1:t2","cwd":"/Users/x/regask/web"}
]}}
EOF
  cat > "$FIX/tabs.json" <<'EOF'
{"result":{"tabs":[
 {"tab_id":"w1:t1","workspace_id":"w1","label":"api","number":1},
 {"tab_id":"w1:t2","workspace_id":"w1","label":"web","number":2}
]}}
EOF

  cat > "$FIX/herdr" <<EOF
#!/opt/homebrew/bin/bash
case "\$1 \$2" in
  "workspace list") cat "$FIX/ws.json" ;;
  "pane list")      cat "$FIX/panes.json" ;;
  "tab list")       cat "$FIX/tabs.json" ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$FIX/herdr"

  # zoxide stub: one path already open as a tab, one not.
  cat > "$FIX/zoxide" <<'EOF'
#!/opt/homebrew/bin/bash
printf '%s\n' /Users/x/regask/api /Users/x/personal/blog
EOF
  chmod +x "$FIX/zoxide"

  export HERDR_ENV=1 HERDR_BIN="$FIX/herdr" PATH="$FIX:$PATH"
}

@test "open tabs are listed with their tab id as the routing target" {
  run "$PICKER" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\tw1:t1'* ]]
  [[ "$output" == *$'\tw1:t2'* ]]
  [[ "$output" == *"LX-REGASK"* ]]
}

@test "a zoxide path already open as a tab is not listed twice" {
  run "$PICKER" --list
  [ "$(grep -c '/Users/x/regask/api' <<< "$output")" -eq 1 ]
}

@test "a zoxide path that is not open is listed as a path target" {
  run "$PICKER" --list
  [[ "$output" == *$'\t/Users/x/personal/blog'* ]]
}

@test "--list emits no tmux calls under herdr" {
  cat > "$FIX/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
echo "TMUX-CALLED" >&2
EOF
  chmod +x "$FIX/tmux"
  run "$PICKER" --list
  [[ "$output" != *"TMUX-CALLED"* ]]
}

@test "outside herdr, --list falls back to tmux windows" {
  cat > "$FIX/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
[[ "$1" == "list-windows" ]] && echo "legacy:1 oldwin"
EOF
  chmod +x "$FIX/tmux"
  run env -u HERDR_ENV "$PICKER" --list
  [[ "$output" == *"legacy:1"* ]]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/herdr/picker.bats`
Expected: all 5 FAIL — `--list` is not a recognised argument, so the picker falls through to `cmd_main` and blocks on fzf or exits non-zero.

- [ ] **Step 3: Add the herdr backend and the `--list` seam**

In `terminals/sesh/sesh-picker.sh`:

Source the primitives after the existing `source .../roots.sh` line from Task 5:

```bash
source "$(dirname "$SCRIPT")/../herdr/lib.sh"
```

Add a herdr list builder next to the existing `build_list`:

```bash
#--------------------------------------------------------------------
# hd_build_list <out>
#   herdr equivalent of build_list. Open tabs first (cyan terminal glyph,
#   routed by tab id), then zoxide paths not already open (yellow bolt,
#   routed by path). Dedup is by pane cwd, so a project appears once.
#--------------------------------------------------------------------
hd_build_list() {
  local out="$1"
  : > "$out"

  local ws_json panes_json open_cwds
  ws_json=$("$HERDR_BIN" workspace list 2>/dev/null)
  open_cwds="$(mktemp)"

  local ws label
  while IFS=$'\t' read -r ws label; do
    [[ -z "$ws" ]] && continue
    panes_json=$("$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null)
    printf '%s\n' "$panes_json" | jq -r '.result.panes[]?.cwd' >> "$open_cwds"

    "$HERDR_BIN" tab list --workspace "$ws" 2>/dev/null \
      | jq -r --arg ws "$label" --arg ic "$ICON_TMUX_FG$ICON_TMUX$RESET" \
          '.result.tabs[]? | "\($ic) \($ws):\(.number) \(.label)\t\(.tab_id)"' >> "$out"
  done < <(printf '%s\n' "$ws_json" \
             | jq -r '.result.workspaces[]? | "\(.workspace_id)\t\(.label)"')

  local path short
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    grep -qxF "$path" "$open_cwds" && continue
    short=$(shorten_path "$path")
    printf '%s%s%s %s\t%s\n' "$ICON_ZOX_FG" "$ICON_ZOX" "$RESET" "$short" "$path" >> "$out"
  done < <(zoxide query -l 2>/dev/null)

  rm -f "$open_cwds"
}
```

Add a herdr preview branch to `cmd_preview`, replacing its `*)` case:

```bash
    *)
      if hd_active; then
        local pane
        pane=$(hd_first_pane_id "$target")
        [[ -z "$pane" ]] && { printf '(no pane)\n'; return 0; }
        "$HERDR_BIN" pane read "$pane" --source recent-unwrapped --lines 20 \
          || printf '(no output)\n'
      else
        tmux capture-pane -t "$target" -p -E - 2>/dev/null | tail -20 \
          || printf '(no window)\n'
      fi
      ;;
```

Add a herdr routing branch. Replace the `*)` case inside `route_selection`'s first `case "$target"` with:

```bash
    *)
      if hd_active; then
        "$HERDR_BIN" tab focus "$target" >/dev/null 2>&1
      else
        tmux switch-client -t "$target"
      fi
      return 0
      ;;
```

and replace the body of the roots loop so path routing uses herdr when active:

```bash
  local name root
  while IFS=$'\t' read -r name root; do
    [[ -z "$name" || -z "$root" ]] && continue

    if hd_active; then
      local ws tab
      if [[ "$expanded" == "$root" ]]; then
        hd_ensure_workspace "$name" "$root" >/dev/null
        return 0
      fi
      if [[ "$expanded" == "$root/"* ]]; then
        ws=$(hd_ensure_workspace "$name" "$root")
        tab=$(hd_tab_id_by_cwd "$ws" "$expanded")
        if [[ -n "$tab" ]]; then
          "$HERDR_BIN" tab focus "$tab" >/dev/null 2>&1
        else
          hd_open_tab "$ws" "$expanded" >/dev/null
        fi
        return 0
      fi
      continue
    fi

    if [[ "$expanded" == "$root" ]]; then
      sesh connect "$name"
      return 0
    fi
    if [[ "$expanded" == "$root/"* ]]; then
      open_in_session "$name" "$expanded"
      return 0
    fi
  done < "$roots_tsv"

  # Under no known root: a standalone workspace of its own.
  if hd_active; then
    "$HERDR_BIN" workspace create --cwd "$expanded" --focus >/dev/null 2>&1
    return 0
  fi
  sesh connect "$target"
```

Pick the backend in `cmd_main` and add the `--list` seam. Replace `build_list "$tmp/all.list"` with:

```bash
  if hd_active; then
    hd_build_list "$tmp/all.list"
  else
    build_list "$tmp/all.list"
  fi
```

Point `ctrl-d` at the right backend by replacing the existing `ctrl-d` bind with:

```bash
    --bind "ctrl-d:execute-silent(bash $SCRIPT --close {2}; bash $SCRIPT --rebuild $tmp/all.list)+reload(cat $tmp/all.list)" \
```

Add the two new subcommands and route `--rebuild` through the backend switch, replacing the trailing `case` block:

```bash
# cmd_close <target> — close a tab (herdr) or window (tmux).
cmd_close() {
  local target="${1:-}"
  [[ -z "$target" ]] && return 0
  case "$target" in
    /*|~*) return 0 ;;  # not open; nothing to close
  esac
  if hd_active; then
    "$HERDR_BIN" tab close "$target" >/dev/null 2>&1
  else
    tmux kill-window -t "$target" 2>/dev/null
  fi
  return 0
}

cmd_rebuild() {
  if hd_active; then
    hd_build_list "${1:-/dev/null}"
  else
    build_list "${1:-/dev/null}"
  fi
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  --rebuild) shift; cmd_rebuild "${1:-/dev/null}" ;;
  --close)   shift; cmd_close "${1:-}" ;;
  --list)    shift; tmp=$(mktemp); cmd_rebuild "$tmp"; cat "$tmp"; rm -f "$tmp" ;;
  *)         cmd_main ;;
esac
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bats tests/herdr/picker.bats`
Expected: 5 PASS.

- [ ] **Step 5: Confirm `tab close` before trusting ctrl-d**

The close signature was never exercised against a live server. Verify against a throwaway tab, not a real one:

```bash
TAB=$(herdr tab create --workspace "$(herdr workspace list | jq -r '.result.workspaces[0].workspace_id')" --cwd /tmp --label scratch | jq -r '.result.tab.tab_id')
herdr tab close "$TAB"
herdr tab list --workspace "${TAB%%:*}" | jq -r '.result.tabs[].tab_id'
```

Expected: `tab close` exits 0 and `$TAB` is gone from the list. If it instead needs a flag, fix `cmd_close` before continuing.

- [ ] **Step 6: Run the whole suite**

Run: `bats tests/herdr/`
Expected: 31 PASS, 0 failures.

- [ ] **Step 7: Verify live**

Press `ctrl+a s`. Expected: open tabs appear with the cyan glyph and closed zoxide projects with the yellow bolt, each project listed once; selecting an open tab focuses it; selecting a subdirectory of `~/LX14/repository/github.com/regask` opens a tab in the existing `LX-REGASK` workspace rather than a new workspace; selecting an unrelated path creates its own workspace; `ctrl-d` closes the highlighted tab and the list refreshes.

- [ ] **Step 8: Commit**

```bash
git add terminals/sesh/sesh-picker.sh tests/herdr/picker.bats
git commit -m "feat(sesh): herdr-backed project picker with open-tab dedup"
```

---

### Task 7: Migration sweep

**Files:**
- Modify: `terminals/notes/note.sh:9-11`
- Create: `terminals/herdr/README.md`

**Interfaces:**
- Consumes: everything above.
- Produces: nothing downstream.

- [ ] **Step 1: Update the stale note.sh comment**

Its comment explains the `NOTES_DIR` fallback in terms of tmux. Replace lines 9-11 with:

```bash
# Neither the tmux server nor the herdr server sources fish config, so a server
# started outside a login shell won't have NOTES_DIR — this fallback is what
# keeps the binding working there.
```

- [ ] **Step 2: Document the keymap**

Create `terminals/herdr/README.md` holding **one** table: every key actually bound in `config.toml`, one row per binding, columns `key | action | tmux equivalent`. Derive the rows from `config.toml` itself, so there is a single place to update when a key changes.

Do **not** restate the spec's rationale, displaced-defaults table, or dropped-bindings list. Open with one line instead:

```markdown
Keymap for herdr. Rationale, displaced defaults, and deliberately-dropped tmux
bindings: `docs/superpowers/specs/2026-08-04-herdr-keybindings-design.md`.
```

- [ ] **Step 3: Confirm the tmux path still works**

```bash
tmux new-session -d -s migrate-check
tmux send-keys -t migrate-check '~/.dotfiles/terminals/sesh/sesh-picker.sh --list' Enter
sleep 1
tmux capture-pane -t migrate-check -p | head -10
tmux kill-session -t migrate-check
```

Expected: tmux windows are listed with the cyan glyph and no herdr calls occur — `HERDR_ENV` is unset in that session, so the tmux backend is selected.

- [ ] **Step 4: Full suite plus config gate**

```bash
bats tests/herdr/
herdr config check
git status --short
```

Expected: 30 PASS; `config: ok` with no `invalid keybinding` lines; no unexpected modified files.

- [ ] **Step 5: Commit**

```bash
git add terminals/notes/note.sh terminals/herdr/README.md
git commit -m "docs(herdr): keymap reference; note.sh comment covers herdr server"
```

---

## Self-Review

**Spec coverage:** Prefix + inherited + remapped + displaced keys → Task 1. Launchers, pane swap, theme toggle → Task 2. Theming section → Task 1 (config) and Task 2 (toggle). Fish autostart → Task 3. Dual-backend scripts → Tasks 5 (playzone) and 6 (picker). Project picker (all four routing cases, preview, ctrl-d) → Task 6. File layout → Task 1 (symlink, bootstrap). `note.sh` comment → Task 7. Spec verification steps 1-7 → Task 1 Step 5, Task 2 Step 6, Task 3 Step 5, Task 5 Step 6, Task 6 Steps 5/7, Task 7 Steps 3/4. No gaps.

**Two deviations from the spec, both simplifications found while pinning the CLI:**
- Directional pane swap needs no `pane neighbor` call — `pane swap --current --direction <dir>` handles the edge case itself, returning `changed:false, reason:"no_neighbor"` at exit 0.
- The spec described cwd→tab lookup loosely as "find a tab whose cwd matches". `tab list` exposes no `cwd`, so it must go through `pane list`. `hd_tab_id_by_cwd` encapsulates this.

**One unverified signature:** `herdr tab close` was never run against a live server (destructive; the live session was the only target available). Task 6 Step 5 verifies it against a throwaway tab before ctrl-d is trusted.

**Type consistency:** `hd_active`, `hd_workspace_id_by_label`, `hd_ensure_workspace`, `hd_tab_id_by_cwd`, `hd_first_pane_id`, `hd_open_tab`, `hd_split_run` are defined in Task 4 and used under those exact names in Tasks 5 and 6. `parse_roots`/`sesh_root_for` defined in Task 5, used in Tasks 5 and 6. `$HERDR_BIN` is the single seam throughout. `shorten_path`, `ICON_TMUX_FG`, `ICON_ZOX_FG`, `ICON_TMUX`, `ICON_ZOX`, `RESET` are pre-existing in `sesh-picker.sh` and reused unchanged by `hd_build_list`.
