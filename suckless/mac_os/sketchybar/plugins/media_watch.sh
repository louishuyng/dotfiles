#!/bin/bash
# media-control stream → send media_update when the now-playing info changes. The periodic poll (media.sh update_freq) is only a backstop
# A track change arrives as several diff lines within 1 s → send once after it goes quiet (1 s). Sending on the first line and dropping the rest would miss the new title
# When the stream ends (adapter died) restart it after 2 s. On start, clean up every earlier watcher and adapter (so they do not pile up on each sketchybar restart)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for p in $(pgrep -f '^/bin/bash .*/plugins/media_watch.sh$'); do [ "$p" = $$ ] || { pkill -P "$p" 2>/dev/null; kill "$p" 2>/dev/null; }; done   # only the earlier watchers and their adapters (anyone else's media-control is left alone)
MC=$(command -v media-control) || exit 0
while pgrep -qx sketchybar; do   # stop when SketchyBar quits. (When the condition was the media item, rc launched this before creating the item, so it exited at once — 2026-10-02)
  "$MC" stream 2>/dev/null | while IFS= read -r _; do
    n=0; while [ $n -lt 5 ] && IFS= read -r -t 1 _; do n=$((n + 1)); done   # ponytail: bash 3.2 only takes whole seconds — reflected 1 s late
    sketchybar --trigger media_update || exit 0
  done
  sleep 2
done
