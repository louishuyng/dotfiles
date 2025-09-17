#!/opt/homebrew/bin/bash

ICON_FONT="Hack Nerd Font:Regular:14"
sketchybar  --add item  time right                                      \
            --set time  update_freq=5                                   \
                        label.padding_left=0                             \
                        icon.font="$ICON_FONT"             \
                        script="$PLUGIN_DIR/time.sh"                    \
