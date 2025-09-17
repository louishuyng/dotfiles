#!/opt/homebrew/bin/bash

source "$HOME/.config/sketchybar/plugins/icon_map_fn.sh"

__icon_map "${INFO}"

if [ "$icon_result" != ":default:" ]; then
  sketchybar --set $NAME label="$INFO" icon="$icon_result"
else
  sketchybar --set $NAME label="$INFO" icon=""
fi
