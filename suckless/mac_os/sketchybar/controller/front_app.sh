#!/usr/bin/env sh

source "$HOME/.config/sketchybar/plugins/icon_map_fn.sh"

icon_map "${INFO}"

ICON_FONT="sketchybar-app-font"

sketchybar --set $NAME label="$INFO |" icon="$icon_result" icon.font="$ICON_FONT:Regular:20"
