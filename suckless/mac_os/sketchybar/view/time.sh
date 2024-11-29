#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar  --add item  time right                                      \
            --set time  update_freq=5                                   \
                        script="$PLUGIN_DIR/time.sh"                    \
