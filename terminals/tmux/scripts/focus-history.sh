#!/bin/bash
# Most-recent-first history of focused "session_id:window_id" targets, kept in
# the global @focus_history option. Drives prefix-Tab across sessions and windows.
#   focus-history.sh record <session-attached> <target>
#   focus-history.sh back <client> <current-target>
set -e

max_entries=30
history=$(tmux show -gqv @focus_history)

case "$1" in
record)
  # session-window-changed also fires for sessions nobody is looking at.
  [ "$2" = 0 ] && exit 0
  target=$3
  kept=$target
  count=1
  for entry in $history; do
    [ "$entry" = "$target" ] && continue
    [ "$count" -ge "$max_entries" ] && break
    kept="$kept $entry"
    count=$((count + 1))
  done
  tmux set -g @focus_history "$kept"
  ;;
back)
  client=$2
  current=$3
  kept=
  destination=
  live=$(tmux list-windows -a -F '#{session_id}:#{window_id}')
  for entry in $history; do
    # Drop targets whose session or window has since been closed.
    grep -qxF "$entry" <<<"$live" || continue
    kept="$kept $entry"
    if [ -z "$destination" ] && [ "$entry" != "$current" ]; then
      destination=$entry
    fi
  done
  tmux set -g @focus_history "${kept# }"
  if [ -n "$destination" ]; then
    tmux switch-client -c "$client" -t "$destination"
  else
    tmux display -c "$client" 'No previous session or window'
  fi
  ;;
esac
