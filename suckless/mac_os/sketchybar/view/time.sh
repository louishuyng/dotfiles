#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar  --add item  time right                                      \
            --set time  update_freq=5                                   \
                        label.padding_left=0                             \
                        icon.padding_left=0                             \
                        script="$PLUGIN_DIR/time.sh"                    \
