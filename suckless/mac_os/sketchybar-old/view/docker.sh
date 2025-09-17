#!/opt/homebrew/bin/bash

sketchybar -m --add item docker right                         \
              --set docker update_freq=180                     \
                    icon="Docker"                                \
                    label=""                                   \
                   label.padding_left=0                             \
                   label.padding_right=0                             \
                   icon.padding_left=0                             \
                   icon.padding_right=7                             \
                    script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
