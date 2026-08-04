#!/opt/homebrew/bin/bash
# herdr CLI primitives shared by the project picker and the playzone helpers.
# Every call goes through $HERDR_BIN so tests can swap in a fixture replayer.
#
# herdr's `tab list` carries no cwd, so every cwd -> tab lookup goes through
# `pane list`, which exposes cwd and tab_id per pane.
#
# Exit-status contract for every function below:
#   0  the herdr call succeeded. Empty stdout means "no match" — not an error.
#   2  the herdr call itself failed (server unreachable, non-zero exit, bad JSON).
#   3  hd_split_run only: the pane was created but the command failed to launch.
#
# Callers MUST distinguish status 2 from status 0 with empty output. Conflating
# them makes hd_ensure_workspace read a transient failure as "absent" and create
# a duplicate workspace.

HERDR_BIN="${HERDR_BIN:-herdr}"

# hd_active
#   True inside a herdr pane. The backend switch for dual-backend scripts.
hd_active() {
  [[ "${HERDR_ENV:-}" == "1" ]]
}

# hd_workspace_id_by_label <label>
hd_workspace_id_by_label() {
  local label="$1" json
  [[ -z "$label" ]] && return 0
  json=$("$HERDR_BIN" workspace list 2>/dev/null) || return 2
  printf '%s' "$json" | jq -r --arg l "$label" \
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
  # Load-bearing: without `|| return 2` a failed lookup looks like "absent" and
  # we create a second workspace with the same label.
  id=$(hd_workspace_id_by_label "$label") || return 2
  if [[ -n "$id" ]]; then
    printf '%s\n' "$id"
    return 0
  fi

  local expanded="${cwd/#\~/$HOME}" out
  mkdir -p "$expanded" || return 2
  out=$("$HERDR_BIN" workspace create --label "$label" --cwd "$expanded" --focus 2>/dev/null) || return 2
  printf '%s' "$out" | jq -r '.result.workspace.workspace_id // empty'
}

# hd_tab_id_by_cwd <workspace_id> <cwd>
#   Print the id of the first tab in <workspace_id> holding a pane rooted at
#   <cwd>. Matches cwd, not foreground_cwd: the pane's root is stable, whereas
#   foreground_cwd drifts as the user cds around.
hd_tab_id_by_cwd() {
  local ws="$1" cwd="$2" json
  [[ -z "$ws" || -z "$cwd" ]] && return 0
  local expanded="${cwd/#\~/$HOME}"
  json=$("$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null) || return 2
  printf '%s' "$json" | jq -r --arg c "$expanded" \
    'first(.result.panes[]? | select(.cwd == $c) | .tab_id) // empty'
}

# hd_first_pane_id <tab_id>
#   Lists all panes instead of deriving the workspace from the tab_id prefix:
#   `pane list` works without --workspace, so nothing here depends on tab ids
#   being formatted "<workspace_id>:<tab>".
hd_first_pane_id() {
  local tab="$1" json
  [[ -z "$tab" ]] && return 0
  json=$("$HERDR_BIN" pane list 2>/dev/null) || return 2
  printf '%s' "$json" | jq -r --arg t "$tab" \
    'first(.result.panes[]? | select(.tab_id == $t) | .pane_id) // empty'
}

# hd_open_tab <workspace_id> <cwd>
hd_open_tab() {
  local ws="$1" cwd="$2" out
  if [[ -z "$ws" || -z "$cwd" ]]; then
    echo "hd_open_tab: missing argument(s)" >&2
    return 2
  fi
  local expanded="${cwd/#\~/$HOME}"
  mkdir -p "$expanded" || return 2
  out=$("$HERDR_BIN" tab create --workspace "$ws" --cwd "$expanded" --focus 2>/dev/null) || return 2
  printf '%s' "$out" | jq -r '.result.tab.tab_id // empty'
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
  # Same guard the siblings use — herdr's behavior on a nonexistent --cwd is
  # unverified, so create it rather than find out.
  mkdir -p "$expanded" || return 2

  local out new
  out=$("$HERDR_BIN" pane split --pane "$pane" --direction "$direction" \
          --ratio "$ratio" --cwd "$expanded" 2>/dev/null) || return 2
  new=$(printf '%s' "$out" | jq -r '.result.pane.pane_id // empty')
  [[ -z "$new" ]] && return 2

  # The split already happened, so on failure the caller is left holding an
  # extra empty pane. Return 3 rather than 0 so it can surface that instead of
  # reporting a command that never launched.
  "$HERDR_BIN" pane run "$new" "$cmd" >/dev/null 2>&1 || return 3
  printf '%s\n' "$new"
}
