#!/opt/homebrew/bin/bash
# Shared helpers for playzone scripts.
# Source from a script via:
#   DIR="$(cd "$(dirname "$0")/.." && pwd)"
#   source "$DIR/lib.sh"

# pz_ensure_session <name>
#   Ensure a tmux session named <name> exists. If it doesn't, create it
#   via `sesh connect` (sesh reads sesh.toml for root/cmd, auto-switches
#   the client when $TMUX is set — no -d flag needed or supported).
pz_ensure_session() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "pz_ensure_session: missing session name" >&2
    return 2
  fi
  if tmux has-session -t "=$name" 2>/dev/null; then
    return 0
  fi
  sesh connect "$name"
}

# pz_open_or_split <session> <cmd> <cwd> <split-flag> <split-size>
#   Locate (or create) a window in <session> whose pane is rooted at <cwd>.
#
#   If a matching window does NOT exist:
#     - create a new window with <cwd> as its starting directory and
#       <cmd> as its starting command
#     - switch client to it
#   If a matching window DOES exist:
#     - switch client to it
#     - split using <split-flag> at <split-size>, also rooted at <cwd>
#     - send-keys "<cmd>" Enter into the new pane
#
#   <cwd> sets the pane's starting directory; its basename drives tmux's
#         automatic-rename, so it also becomes the displayed window name.
#   <split-flag> is "-v" (split below) or "-h" (split right).
#   <split-size> is e.g. "30%".
pz_open_or_split() {
  local session="$1" cmd="$2" cwd="$3" split_flag="$4" split_size="$5"

  if [[ -z "$session" || -z "$cmd" || -z "$cwd" || -z "$split_flag" || -z "$split_size" ]]; then
    echo "pz_open_or_split: missing argument(s)" >&2
    return 2
  fi

  local expanded_cwd="${cwd/#\~/$HOME}"
  [[ -d "$expanded_cwd" ]] || mkdir -p "$expanded_cwd"

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
