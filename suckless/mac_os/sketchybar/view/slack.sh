#!/usr/bin/env sh

sketchybar  --add   item slack right \
            --set   slack \
                    update_freq=60 \
                    script="$PLUGIN_DIR/slack.sh" \
                    label.font="$LABEL:Bold:12"                     \
                    icon.font.size=25 \
           --subscribe slack system_woke
