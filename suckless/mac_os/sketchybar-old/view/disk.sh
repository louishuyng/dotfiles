#!/opt/homebrew/bin/bash

sketchybar --add item disk right                              \
           --set disk script="$PLUGIN_DIR/disk.sh"            \
                      label.padding_left=0                             \
                      label.padding_right=2                             \
                      update_freq=300                           \
