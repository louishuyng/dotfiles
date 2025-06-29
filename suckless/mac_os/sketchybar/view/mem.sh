#!/usr/bin/env sh

sketchybar -m --add item ram right                         \
              --set ram update_freq=5                      \
                    label.padding_left=0                             \
                    label.padding_right=2                             \
                    ram script="$PLUGIN_DIR/mem.sh"        \
