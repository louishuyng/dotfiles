#!/usr/bin/env sh

source "$HOME/.config/sketchybar/plugins/icon_map_fn.sh"

icon_map "${INFO}"

sketchybar --set $NAME label="$INFO " icon="$icon_result"
