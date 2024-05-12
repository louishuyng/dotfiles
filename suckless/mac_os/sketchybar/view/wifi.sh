#!/bin/bash

WIFI_DISCONNECTED=􀙈

wifi=(
  label.width=0
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item space_separator_wifi right                              \
           --set space_separator_wifi icon="|"                                 \
                                 icon.font="$LABEL:SemiBold:12"         \
                                 background.padding_left=0              \
                                 icon.padding_right=0                             \
                                 label.padding_right=0                             \

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change mouse.clicked

