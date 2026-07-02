#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/front_app.sh

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set $NAME \
    label="" label.drawing=off \
    icon.background.image="app.$INFO" \
    icon.background.image.scale=0.9
fi
