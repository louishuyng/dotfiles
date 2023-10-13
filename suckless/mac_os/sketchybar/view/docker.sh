#!/usr/bin/env sh

sketchybar -m --add item docker left                         \
              --set docker update_freq=5                     \
                    icon="🐳"                                \
                    icon.y_offset=1                          \
                    label.y_offset=-1                          \
                    label.padding_right=7                             \
                    icon.font="$LABEL:Bold:12"          \
                    script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
