#!/usr/bin/env sh

INDEX=$(/opt/homebrew/bin/yabai -m query --spaces --space | jq .index)

if [ "$INDEX" -eq 1 ]; then
  ICON="􀯱"
elif [ "$INDEX" -eq 2 ]; then
  ICON="􀯲"
else
  ICON="􀯳"
fi

sketchybar --set $NAME label="$INDEX" icon="$ICON"
