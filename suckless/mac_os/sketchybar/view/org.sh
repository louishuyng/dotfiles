#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar -m --add item org left                         \
              --set org update_freq=10                     \
                    icon="􀧵"                                \
                    label.y_offset=-1                          \
                    icon.y_offset=-1                          \
                    label.font="$LABEL:Bold:12"                     \
                    icon.font="$ICON_FONT:Regular:12"                 \
                    script="$PLUGIN_DIR/org.sh"       \
