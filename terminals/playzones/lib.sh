#!/opt/homebrew/bin/bash
# Shared helpers for playzone scripts.
# Source from a script via:
#   DIR="$(cd "$(dirname "$0")/.." && pwd)"
#   source "$DIR/lib.sh"
#
# Three backends: herdr inside a herdr pane (HERDR_ENV=1), the Herdr app inside
# one of its terminals (pa_active), tmux otherwise.

_PZ_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_PZ_DIR/../herdr/lib.sh"
source "$_PZ_DIR/../sesh/roots.sh"

HERDR_APP_BIN="${HERDR_APP_BIN:-herdr-app}"

# pa_active
#   True inside a Herdr app terminal: herdr-core gives each one its socket.
#   tmux and the herdr TUI win, as in hd_active.
pa_active() {
  [[ -z "${TMUX:-}" && "${HERDR_ENV:-}" != "1" && -n "${HC_TERMINAL_SOCKET:-}" ]] \
    && command -v "$HERDR_APP_BIN" >/dev/null
}

# pa_space_id <name>
#   The id of the Herdr app space called <name>, or nothing.
pa_space_id() {
  "$HERDR_APP_BIN" ls | jq -er --arg n "$1" '[.spaces[] | select(.name == $n) | .id][0] // empty'
}

# pa_pane_in <space-id> <cwd>
#   "<tab-id> <pane-id>" of the first terminal in the space whose cwd is <cwd>.
#   `herdr-app ls` has no cwd, so each terminal is asked through hc.
pa_pane_in() {
  local space="$1" cwd="$2" tab pane term
  while read -r tab pane term; do
    [[ "$(hc get "$term" --json 2>/dev/null | jq -r '.cwd // empty')" == "$cwd" ]] && { echo "$tab $pane"; return 0; }
  done < <("$HERDR_APP_BIN" ls | jq -r --arg s "$space" '.spaces[] | select(.id == $s) | .tabs[] | .id as $t | .terminals[] | "\($t) \(.pane) \(.terminal)"')
  return 0
}

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

  if pa_active; then
    [[ -n "$(pa_space_id "$name")" ]] && return 0
    local root
    root=$(sesh_root_for "$name")
    if [[ -z "$root" ]]; then
      echo "pz_ensure_session: no sesh.toml root for '$name'" >&2
      return 2
    fi
    "$HERDR_APP_BIN" do space.new --name "$name" --folder "$root" >/dev/null || return 2
    return 0
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
#
#   Exit status (herdr path):
#     0  tab located/created and command launched (or split+run succeeded).
#     1  no workspace '<session>' — pz_ensure_session was not called first.
#     2  a herdr call failed, or bad arguments.
#     3  the tab/pane was created (new tab, or split) but its command failed
#        to launch — a playzone hitting this means the pane exists but never
#        ran the command, so it's surfaced rather than swallowed.
pz_open_or_split() {
  local session="$1" cmd="$2" cwd="$3" split_flag="$4" split_size="$5"

  if [[ -z "$session" || -z "$cmd" || -z "$cwd" || -z "$split_flag" || -z "$split_size" ]]; then
    echo "pz_open_or_split: missing argument(s)" >&2
    return 2
  fi

  local expanded_cwd="${cwd/#\~/$HOME}"
  [[ -d "$expanded_cwd" ]] || mkdir -p "$expanded_cwd"

  if pa_active; then
    local space found tab pane direction weight argv
    space=$(pa_space_id "$session") || return 2
    if [[ -z "$space" ]]; then
      echo "pz_open_or_split: no space '$session' — call pz_ensure_session first" >&2
      return 1
    fi
    case "$split_flag" in
      -v) direction="down" ;;
      -h) direction="right" ;;
      *)  echo "pz_open_or_split: bad split flag '$split_flag'" >&2; return 2 ;;
    esac
    argv=$(jq -cn --arg c "$cmd" '["fish", "-lc", $c]')
    found=$(pa_pane_in "$space" "$expanded_cwd") || return 2
    if [[ -z "$found" ]]; then
      tab=$("$HERDR_APP_BIN" do tab.new --space "$space" --folder "$expanded_cwd" --name "$(basename "$expanded_cwd")" --argv "$argv" | jq -er .tab) || return 3
      "$HERDR_APP_BIN" do tab.select --id "$tab" >/dev/null
      return 0
    fi
    read -r tab pane <<< "$found"
    "$HERDR_APP_BIN" do tab.select --id "$tab" >/dev/null || return 2
    pane=$("$HERDR_APP_BIN" do pane.split --direction "$direction" --pane "$pane" --argv "$argv" | jq -er .pane) || return 3
    # The new pane's weight against its sibling's 1, as scripts/pane-split.sh: p/(1-p).
    weight=$(awk -v s="${split_size%\%}" 'BEGIN { printf "%.4f", s / (100 - s) }')
    "$HERDR_APP_BIN" do layout.resize --id "$pane" --weight "$weight" >/dev/null
    return 0
  fi

  if hd_active; then
    local ws tab existed direction ratio pane
    # `|| return 2` distinguishes a failed herdr call from a genuinely absent
    # workspace; without it a transient failure looks like "not created yet".
    ws=$(hd_workspace_id_by_label "$session") || return 2
    if [[ -z "$ws" ]]; then
      echo "pz_open_or_split: no workspace '$session' — call pz_ensure_session first" >&2
      return 1
    fi

    case "$split_flag" in
      -v) direction="down" ;;
      -h) direction="right" ;;
      *)  echo "pz_open_or_split: bad split flag '$split_flag'" >&2; return 2 ;;
    esac
    # herdr's --ratio sizes the EXISTING pane, not the new one (verified
    # empirically), so tmux's "new pane gets split_size" is the inverse:
    # ratio = (100 - size) / 100. size=30% -> 0.70, leaving the new pane at 30%.
    ratio=$(awk -v s="${split_size%\%}" 'BEGIN { printf "%.2f", (100 - s) / 100 }')

    # hd_open_project does the find-or-create-tab dance itself (the same one
    # this function used to duplicate), but doesn't say which branch it took —
    # and split-vs-run depends on that — so check first.
    tab=$(hd_tab_id_by_cwd "$ws" "$expanded_cwd") || return 2
    existed=0
    [[ -n "$tab" ]] && existed=1

    tab=$(hd_open_project "$session" "$expanded_cwd") || return 2
    [[ -z "$tab" ]] && return 2
    pane=$(hd_first_pane_id "$tab") || return 2

    if (( existed )); then
      hd_split_run "$pane" "$direction" "$ratio" "$expanded_cwd" "$cmd" >/dev/null
      return $?
    fi
    # Same status-3 meaning as hd_split_run: the tab/pane now exists, but a
    # non-zero exit here means <cmd> never launched in it — don't swallow that.
    "${HERDR_BIN:-herdr}" pane run "$pane" "$cmd" >/dev/null 2>&1 || return 3
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
