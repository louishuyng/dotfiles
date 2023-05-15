#!/usr/bin/env sh

sketchybar -m --add item docker left                         \
              --set docker update_freq=5                     \
                    icon="🐳"                                \
                    icon.y_offset=2                          \
                    label.y_offset=-1                          \
                    icon.font="$LABEL:Bold:14"          \
                    label.padding_left=-1                    \
                    cpu script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
