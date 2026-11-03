#!/bin/bash
# hc events stream (herdr-core) → send agent_status_change when a terminal starts, ends, or changes status. pilo.sh debounces bursts; its 30 s poll is the backstop
# When the stream ends (core restarted) restart it after 2 s. On start, clean up every earlier watcher and its stream (so they do not pile up on each sketchybar restart)
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
for p in $(pgrep -f '^/bin/bash .*/plugins/agent_watch.sh$'); do [ "$p" = $$ ] || { pkill -P "$p" 2>/dev/null; kill "$p" 2>/dev/null; }; done
command -v hc >/dev/null || exit 0
while pgrep -qx sketchybar; do
  # Skips the opening snapshot ("terminals"), heartbeats, and label edits: none of them change an agent
  hc events --json 2>/dev/null | grep --line-buffered -v -e '"terminals":' -e '"heartbeat"' -e '"type":"labels"' | while IFS= read -r _; do
    sketchybar --trigger agent_status_change || exit 0
  done
  sleep 2
done
