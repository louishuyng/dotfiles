#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

sketchybar  --add   item slack right \
            --set   slack \
                    update_freq=30 \
                    script="$PLUGIN_DIR/slack.sh" \
                    icon=":slack:" \
                    icon.font="$ICON_FONT:Regular:15"                 \
                    label.font="$LABEL:Bold:12"                     \
           --subscribe slack system_woke
