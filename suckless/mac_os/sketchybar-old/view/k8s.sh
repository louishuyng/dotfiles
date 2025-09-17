#!/opt/homebrew/bin/bash

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item k8s right                         \
              --set k8s update_freq=180                     \
                    icon.padding_left=0                             \
                    label.padding_left=0                             \
                    label.color="0xffD5C0FA" \
                    script="$PLUGIN_DIR/k8s.sh"       \
