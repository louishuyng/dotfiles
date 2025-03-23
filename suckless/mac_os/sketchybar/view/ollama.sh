#!/usr/bin/env bash

ICON_FONT="sketchybar-app-font"

sketchybar -m --add item ollama right \
              --set ollama update_freq=10 \
                        icon=":openai:"                                \
                        icon.font="$ICON_FONT:Regular:14"                 \
                        label="" \
                        script="$PLUGIN_DIR/ollama.sh" \
                        click_script="$PLUGIN_DIR/toggle_ollama.sh" \
