#!/opt/homebrew/bin/bash

sketchybar --add item weather right \
  --set weather  \
  script="$PLUGIN_DIR/weather.sh" \
  update_freq=1500 \
  --subscribe weather mouse.clicked

