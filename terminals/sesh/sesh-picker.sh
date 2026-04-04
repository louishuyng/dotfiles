#!/bin/bash
selected=$(sesh list | fzf \
  --no-sort --ansi --no-preview \
  --border-label ' sesh ' --prompt '⚡  ' \
  --header '  ^a all ^t tmux ^g configs ^x zoxide' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
  --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
  --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
  --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)')

[ -z "$selected" ] && exit 0

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
