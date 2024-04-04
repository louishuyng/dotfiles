#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item docker right                         \
              --set docker update_freq=180                     \
                    icon=":insomnia:"                                \
                    icon.padding_right=0                             \
                    label.padding_right=0                             \
                    label.padding_left=0                             \
                    icon.font="$ICON_FONT:Regular:15"                 \
                    script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
