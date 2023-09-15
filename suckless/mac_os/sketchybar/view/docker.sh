#!/usr/bin/env sh

sketchybar -m --add item docker left                         \
              --set docker update_freq=5                     \
                    icon="🐳"                                \
                    icon.y_offset=2                          \
                    label.y_offset=-1                          \
                    icon.font="$LABEL:Bold:13"          \
                    cpu script="$PLUGIN_DIR/docker.sh"       \
                    click_script="$PLUGIN_DIR/toggle_docker.sh" \
