#!/bin/bash

WIFI_DISCONNECTED=􀙈

wifi=(
  label.width=0
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
                 icon.font="$LABEL:SemiBold:14"         \
                 icon.padding_left=0                             \
           --subscribe wifi wifi_change mouse.clicked theme_change

