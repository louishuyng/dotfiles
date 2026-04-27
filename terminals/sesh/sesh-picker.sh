#!/opt/homebrew/bin/bash

SCRIPT="$(realpath "$0")"
SESH_TOML="${SESH_TOML:-$HOME/.config/sesh/sesh.toml}"

#--------------------------------------------------------------------
# parse_roots <out_path>
# Parse sesh.toml into TSV "name<TAB>expanded_path" lines.
# If sesh.toml is missing, writes an empty file and returns 0.
#--------------------------------------------------------------------
parse_roots() {
  local out="$1"
  : > "$out"
  [[ -r "$SESH_TOML" ]] || return 0

  local current_name=""
  local line
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

#--------------------------------------------------------------------
# tmux_list — one session name per line, empty if no tmux server
#--------------------------------------------------------------------
tmux_list() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null || true
}

#--------------------------------------------------------------------
# tmux_has_match <query>
# 0 if any tmux session name contains query (case-insensitive); 1 otherwise.
# Empty query returns 0 (treated as "match anything").
#--------------------------------------------------------------------
tmux_has_match() {
  local query="${1:-}"
  [[ -z "$query" ]] && return 0
  local q_lc="${query,,}"
  local name n_lc
  while IFS= read -r name; do
    n_lc="${name,,}"
    [[ "$n_lc" == *"$q_lc"* ]] && return 0
  done < <(tmux_list)
  return 1
}

#--------------------------------------------------------------------
# cmd_source <query>
#--------------------------------------------------------------------
cmd_source() {
  local query="${1:-}"
  if tmux_has_match "$query"; then
    tmux_list
  else
    zoxide query -l 2>/dev/null || true
  fi
}

#--------------------------------------------------------------------
# cmd_prompt <query>
#--------------------------------------------------------------------
cmd_prompt() {
  local query="${1:-}"
  if tmux_has_match "$query"; then
    printf '  tmux ❯ '
  else
    printf '  zoxide ❯ '
  fi
}
#--------------------------------------------------------------------
# cmd_preview <line>
# If line is an active tmux session: show windows + git status of first window.
# Else treat line as a path: show directory tree (eza if available, else ls).
#--------------------------------------------------------------------
cmd_preview() {
  local line="${1:-}"
  [[ -z "$line" ]] && return 0

  if tmux has-session -t "$line" 2>/dev/null; then
    printf 'Session: %s\n\n' "$line"
    tmux list-windows -t "$line" -F '#I  #W  (#{pane_current_path})' 2>/dev/null

    local first_path
    first_path=$(tmux list-windows -t "$line" -F '#{pane_current_path}' 2>/dev/null | head -1)
    if [[ -n "$first_path" ]] && git -C "$first_path" rev-parse --git-dir >/dev/null 2>&1; then
      printf '\n── git ──\n'
      printf 'branch: %s\n' "$(git -C "$first_path" branch --show-current 2>/dev/null)"
      local dirty
      dirty=$(git -C "$first_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      printf 'dirty:  %s files\n' "$dirty"
      printf 'recent:\n'
      git -C "$first_path" log --oneline -3 2>/dev/null | sed 's/^/  /'
    fi
    return 0
  fi

  local expanded="${line/#\~/$HOME}"
  if command -v eza >/dev/null 2>&1; then
    eza --tree --level=2 --color=always --icons --git-ignore "$expanded" 2>/dev/null \
      || printf '(path not found: %s)\n' "$expanded"
  else
    ls -la "$expanded" 2>/dev/null \
      || printf '(path not found: %s)\n' "$expanded"
  fi
}
#--------------------------------------------------------------------
# open_in_session <session> <path>
# Find an existing window in <session> whose pane_current_path == <path>
# and switch to it; else create a new window in that session at <path>.
#--------------------------------------------------------------------
open_in_session() {
  local session="$1" path="$2"
  local existing
  existing=$(tmux list-windows -t "$session" -F '#{window_index} #{pane_current_path}' 2>/dev/null \
    | awk -v p="$path" '$2 == p {print $1; exit}')

  if [[ -n "$existing" ]]; then
    tmux switch-client -t "$session:$existing"
  else
    tmux new-window -t "$session" -c "$path" 2>/dev/null \
      || tmux new-session -d -s "$session" -c "$path"
    tmux switch-client -t "$session"
  fi
}

#--------------------------------------------------------------------
# route_selection <selected> <roots_tsv>
#--------------------------------------------------------------------
route_selection() {
  local selected="$1" roots_tsv="$2"
  [[ -z "$selected" ]] && return 0

  if tmux has-session -t "$selected" 2>/dev/null; then
    tmux switch-client -t "$selected"
    return 0
  fi

  local expanded="${selected/#\~/$HOME}"

  local name root
  while IFS=$'\t' read -r name root; do
    [[ -z "$name" || -z "$root" ]] && continue
    if [[ "$expanded" == "$root" ]]; then
      sesh connect "$name"
      return 0
    fi
    if [[ "$expanded" == "$root/"* ]]; then
      open_in_session "$name" "$expanded"
      return 0
    fi
  done < "$roots_tsv"

  sesh connect "$selected"
}

#--------------------------------------------------------------------
# cmd_main
#--------------------------------------------------------------------
cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/sesh-picker.XXXXXX")
  trap 'rm -rf "$tmp"' EXIT

  parse_roots "$tmp/roots.tsv"

  local selected
  selected=$(tmux_list | fzf \
    --ansi --no-sort --border none --padding 0 --margin 0 \
    --pointer '▌' --marker '▍' \
    --header 'enter: open   ^d: kill session' \
    --header-first \
    --prompt '  tmux ❯ ' \
    --bind 'tab:down,btab:up' \
    --bind "change:transform-list-source(bash $SCRIPT --source {q})+transform-prompt(bash $SCRIPT --prompt {q})" \
    --bind 'ctrl-d:execute-silent(tmux kill-session -t {} 2>/dev/null)+reload(tmux list-sessions -F "#{session_name}" 2>/dev/null)' \
    --preview "bash $SCRIPT --preview {}" \
    --preview-window 'right:55%:wrap')

  [[ -z "$selected" ]] && exit 0
  route_selection "$selected" "$tmp/roots.tsv"
}

case "${1:-}" in
  --source)  shift; cmd_source  "${1:-}" ;;
  --prompt)  shift; cmd_prompt  "${1:-}" ;;
  --preview) shift; cmd_preview "${1:-}" ;;
  *)         cmd_main ;;
esac
