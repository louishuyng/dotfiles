#!/opt/homebrew/bin/bash

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item ai right \
              --set ai update_freq=10 \
                        script="$PLUGIN_DIR/ai.sh" \
                        click_script="$PLUGIN_DIR/toggle_ai.sh" \
