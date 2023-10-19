#!/usr/bin/env sh

sketchybar -m --add item k8s left                         \
              --set k8s update_freq=5                     \
                    icon="🕸️"                                \
                    icon.y_offset=1                          \
                    label.y_offset=-1                          \
                    label.padding_right=7                             \
                    icon.font="$LABEL:Bold:12"         \
                    script="$PLUGIN_DIR/k8s.sh"       \
