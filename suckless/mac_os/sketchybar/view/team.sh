#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

export BLUE=0xff4F54BB

sketchybar  --add   item team right \
            --set   team \
                    update_freq=30 \
                    script="$PLUGIN_DIR/team.sh" \
                    label.font="$LABEL:Bold:12"                     \
                    icon=":microsoft_teams:" \
                    icon.font="$ICON_FONT:Regular:15"                 \
                    icon.color=$BLUE             \
                    label.color=$BLUE            \
           --subscribe team system_woke
