#!/bin/bash

#Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/items/front_app.sh

front_app=(
  icon.padding_right=0
  label.padding_left=4
  label.padding_right=0
  padding_right=25
  # Using default "SF Pro"
  icon.font="sketchybar-app-font:Regular:18"
  # label.font="$FONT:Black:13.0"
  label.color=$MAGENTA
  icon.color=$MAGENTA
  icon.background.drawing=off
  display=active
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
)

sketchybar --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched
