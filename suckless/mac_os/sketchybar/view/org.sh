#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar -m --add item org left                         \
              --set org update_freq=10                     \
                    icon="􁕜"                                \
                    label.font="$LABEL:Bold:13"                     \
                    icon.font="$ICON_FONT:Regular:13"                 \
                    script="$PLUGIN_DIR/org.sh"       \
