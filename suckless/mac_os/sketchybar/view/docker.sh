#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item docker right                         \
              --set docker update_freq=180                     \
                    icon=":orbstack:"                                \
                    icon.font="$ICON_FONT:Regular:15"                 \
                    label=""                                   \
                    script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
