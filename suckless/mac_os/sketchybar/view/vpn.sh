#!/usr/bin/env bash

sketchybar -m --add item vpn right \
              --set vpn update_freq=30 \
                        icon= \
                        icon.font="$LABEL:Bold:15"                      \
                        icon.padding_right=3 \
                        label.padding_right=7 \
                        script="$PLUGIN_DIR/vpn.sh"
