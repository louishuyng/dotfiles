#!/usr/bin/env bash

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item vpn right \
              --set vpn update_freq=10 \
                        icon=":nord_vpn:"                                \
                        icon.font="$ICON_FONT:Regular:15 "                 \
                        label="" \
                        script="$PLUGIN_DIR/vpn.sh" \
                        click_script="$PLUGIN_DIR/toggle_vpn.sh" \

