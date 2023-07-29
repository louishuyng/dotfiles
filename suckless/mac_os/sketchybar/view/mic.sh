#!/usr/bin/env sh
#
sketchybar -m --add item mic right \
sketchybar -m --set mic update_freq=3 \
              --set mic script="$PLUGIN_DIR/mic.sh" \
              --set mic click_script="$PLUGIN_DIR/mic_click.sh" \
              icon.font="$LABEL:Bold:15"          \
