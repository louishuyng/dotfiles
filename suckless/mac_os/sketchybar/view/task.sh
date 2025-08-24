#!/opt/homebrew/bin/bash

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item task right \
              --set task update_freq=10 \
                        icon=":superproductivity:"                                \
                        icon.font="$ICON_FONT:Regular:15"                 \
                        icon.padding_right=3 \
                        icon.color="0xff0D63DE" \
                        label.padding_right=5 \
                        script="$PLUGIN_DIR/task.sh" \
                        click_script="$PLUGIN_DIR/open_task.sh"
