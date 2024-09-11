#!/usr/bin/env bash

sketchybar -m --add item ollama right \
              --set ollama update_freq=10 \
                        icon.font="$LABEL:Bold:16"                      \
                        icon.padding_right=3 \
                        label.padding_right=7 \
                        script="$PLUGIN_DIR/ollama.sh" \
                        click_script="$PLUGIN_DIR/toggle_ollama.sh" \
