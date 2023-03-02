#!/usr/bin/env sh

sketchybar -m --add item ram right                         \
              --set ram update_freq=1                      \
                    ram script="$PLUGIN_DIR/mem.sh"        \
