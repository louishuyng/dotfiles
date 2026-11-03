#!/bin/bash

resize_left_label() {
  local item="$1" text="$2" cache="$HOME/.cache/sketchybar/$3"
  local lock="$HOME/.cache/sketchybar/front_app.lock" acquired=0
  local old_width padding width query props
  # A holder killed mid-update (reload, sleep) never removes the lock; holders finish in ~2s.
  [ -d "$lock" ] && [ $(( $(date +%s) - $(stat -f %m "$lock") )) -gt 10 ] && rmdir "$lock" 2>/dev/null || true
  for _ in $(seq 40); do
    if mkdir "$lock" 2>/dev/null; then acquired=1; break; fi
    sleep 0.05
  done
  [ "$acquired" = 1 ] || return 0
  trap 'rmdir "$HOME/.cache/sketchybar/front_app.lock" 2>/dev/null' EXIT

  # Read after taking the lock so queued events use the current workspace/app.
  if [ "$item" = wordmark ]; then
    text=$(timeout 3 aerospace list-workspaces --focused) || return 0
  elif [ -z "$SB_BOOT" ]; then
    local front
    front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | perl -ne 'print /^"LSDisplayName"="(.*)"$/ ? $1 : /^"([^\"]+)"/ ? $1 : "" if $. == 1')
    if [ -n "$front" ]; then
      case "$front" in
        'Visual Studio Code'|Code) text=code ;;
        'Google Chrome') text=chrome ;;
        *) text=$(tr '[:upper:]' '[:lower:]' <<< "$front") ;;
      esac
    fi
  fi
  [ -n "$text" ] || return 0
  [ "$text" != "$(cat "$cache" 2>/dev/null)" ] || return 0

  for _ in 1 2 3; do
    query=$(sketchybar --query "$item")
    [ -n "$query" ] && break
    sleep 0.05
  done
  props=$(printf '%s' "$query" | python3 -c '
import json, sys
d = json.load(sys.stdin)
label, geometry = d["label"], d["geometry"]
width = label["width"]
if width <= 0:
    bounds = next(iter(d["bounding_rects"].values()))
    width = bounds["size"][0] - geometry["padding_left"] - geometry["padding_right"]
print(round(width), label["padding_left"] + label["padding_right"])
') || return 0
  read -r old_width padding <<< "$props"
  width=$(( $(perl "$CONFIG_DIR/plugins/width.pl" "$text") + padding ))

  if [ -n "$SB_BOOT" ]; then
    sketchybar --set "$item" label="$text" label.width="$width"
  else
    # One SketchyBar command animates the title and the media width.
    LEFT_ITEM="$item" LEFT_TEXT="$text" LEFT_OLD_WIDTH="$old_width" LEFT_WIDTH="$width" \
      LE_GROW="$((width - old_width))" SENDER=media_layout bash "$CONFIG_DIR/plugins/media.sh"
    sleep 0.22
  fi
  printf '%s\n' "$text" > "$cache"
}
