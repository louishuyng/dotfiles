#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar  --add item  time right                                      \
            --set time  update_freq=5                                   \
                        icon.font="$ICON_FONT:Regular:13"                 \
                        icon=":calendar:"                                 \
                        script="$PLUGIN_DIR/time.sh"                    \
