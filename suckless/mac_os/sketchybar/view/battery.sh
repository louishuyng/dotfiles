#!/usr/bin/env sh

ICON_FONT="Hack Nerd Font:Regular:16"
sketchybar --add item    battery right                                  \
           --subscribe   battery system_woke                            \
           --set battery update_freq=20                                  \
                         icon.font="$ICON_FONT"             \
                         icon.padding_right=0                             \
                         script="$PLUGIN_DIR/battery.sh"                \
