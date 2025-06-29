#!/bin/bash

wifi=(
  label.width=0
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
                 label.padding_left=5                             \
                 label.padding_right=0                             \
                 icon.padding_left=0                             \
                 icon.padding_right=0                             \
           --subscribe wifi wifi_change mouse.clicked theme_change

