#!/usr/bin/env sh

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams (work or school)")
LABEL=""

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"
  sketchybar --set $NAME label="${LABEL}" label.drawing=on
else
  sketchybar --set $NAME label.drawing=off icon.drawing=off
fi
