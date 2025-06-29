#!/usr/bin/env sh

sketchybar -m --add item cpu right                         \
              --set cpu update_freq=5                      \
                    label.padding_left=0                             \
                    label.padding_right=2                             \
                    cpu script="$PLUGIN_DIR/cpu.sh"        right\
