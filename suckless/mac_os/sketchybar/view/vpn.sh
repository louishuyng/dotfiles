#!/usr/bin/env bash

sketchybar -m --add item vpn right \
              --set vpn update_freq=10 \
                        icon="VPN"                                \
                        label="" \
                       label.padding_left=0                             \
                       label.padding_right=0                             \
                       icon.padding_left=0                             \
                       icon.padding_right=7                             \
                        script="$PLUGIN_DIR/vpn.sh" \
                        click_script="$PLUGIN_DIR/toggle_vpn.sh" \

