#!/bin/bash

# Tokyo Night color palette
TN_BG="#1a1b26"
TN_FG="#c0caf5"
TN_BLUE="#7aa2f7"
TN_CYAN="#7dcfff"
TN_GREEN="#9ece6a"
TN_MAGENTA="#bb9af7"
TN_COMMENT="#565f89"
TN_SELECTION="#283457"
TN_BORDER="#3b4261"

selected=$(sesh list -iH | fzf \
  --no-sort --ansi \
  --border none \
  --no-preview \
  --prompt '  ' \
  --pointer '▌' \
  --marker '▍' \
  --header '  ^a all  ^t tmux  ^g configs  ^x zoxide  ^d kill' \
  --header-first \
  --padding 0 \
  --margin 0 \
  --color "bg:$TN_BG,fg:$TN_FG" \
  --color "bg+:$TN_SELECTION,fg+:$TN_BLUE" \
  --color "hl:$TN_MAGENTA,hl+:$TN_MAGENTA" \
  --color "header:$TN_COMMENT" \
  --color "prompt:$TN_CYAN" \
  --color "pointer:$TN_BLUE,marker:$TN_GREEN" \
  --color "info:$TN_COMMENT,spinner:$TN_MAGENTA" \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(  )+reload(sesh list -iH)' \
  --bind 'ctrl-t:change-prompt(  )+reload(sesh list -itH)' \
  --bind 'ctrl-g:change-prompt(  )+reload(sesh list -icH)' \
  --bind 'ctrl-x:change-prompt(  )+reload(sesh list -izH)' \
  --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(sesh list -iH)')

[ -z "$selected" ] && exit 0

# Strip ANSI color codes and icon prefix from selection
selected=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g; s/^[^ ]* //')

open_in_session() {
  local session="$1"
  local path="$2"

  local existing
  existing=$(tmux list-windows -t "$session" -F "#{window_index} #{pane_current_path}" 2>/dev/null \
    | awk -v p="$path" '$2 == p {print $1}')

  if [[ -n "$existing" ]]; then
    tmux switch-client -t "$session:$existing"
  else
    tmux new-window -t "$session" -c "$path" 2>/dev/null \
      || tmux new-session -d -s "$session" -c "$path"
    tmux switch-client -t "$session"
  fi
}

# Expand ~ in selected for comparison
expanded="${selected/#\~/$HOME}"

# Parse sesh.toml and route to parent session if path is under a configured root
toml="$HOME/.config/sesh/sesh.toml"
current_name=""
while IFS= read -r line; do
  if [[ "$line" =~ ^name\ =\ \"(.+)\" ]]; then
    current_name="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^path\ =\ \"(.+)\" ]] && [[ -n "$current_name" ]]; then
    root="${BASH_REMATCH[1]/#\~/$HOME}"
    if [[ "$expanded" == "$root" || "$expanded" == "$root/"* ]]; then
      open_in_session "$current_name" "$expanded"
      exit 0
    fi
    current_name=""
  fi
done < "$toml"

sesh connect "$selected"
