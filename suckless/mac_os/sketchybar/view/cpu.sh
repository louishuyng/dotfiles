#!/usr/bin/env sh

sketchybar -m --add item cpu right                         \
              --set cpu update_freq=5                      \
                    icon.padding_left=0                           \
                    cpu script="$PLUGIN_DIR/cpu.sh"        \
