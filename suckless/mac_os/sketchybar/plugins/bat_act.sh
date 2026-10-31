#!/bin/bash
# Battery popup button. lid: block sleep with caffeinate -dims (pid saved) / kill that pid. No admin rights needed
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"; C="$HOME/.cache/sketchybar"
case "$1" in
  lid)
    if kill -0 "$(cat "$C/caffeinate.pid" 2>/dev/null)" 2>/dev/null; then kill "$(cat "$C/caffeinate.pid")"; rm -f "$C/caffeinate.pid"
    else (nohup caffeinate -dims >/dev/null 2>&1 & echo $! > "$C/caffeinate.pid"); sleep 0.2; fi ;;
esac
SENDER=routine bash "$CONFIG_DIR/plugins/bat.sh"
