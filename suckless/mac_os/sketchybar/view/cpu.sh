#!/usr/bin/env sh

sketchybar -m --add item cpu right                         \
              --set cpu update_freq=1                      \
                    cpu script="$PLUGIN_DIR/cpu.sh"        \

