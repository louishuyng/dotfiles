#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

export BLUE=0xff4F54BB

sketchybar --add item space_separator_2 left                              \
           --set space_separator_2 icon="|"                                 \
                                 icon.font="$LABEL:SemiBold:12"         \
                                 background.padding_left=0              \
                                 icon.padding_right=3                             \
                                 label.padding_right=0                             \

sketchybar  --add   item team left \
            --set   team \
                    update_freq=60 \
                    script="$PLUGIN_DIR/team.sh" \
                    label.font="$LABEL:Bold:12"                     \
                    icon=":microsoft_teams:" \
                    icon.font="$ICON_FONT:Regular:15"                 \
                    icon.color=$BLUE             \
                    label.color=$BLUE            \
           --subscribe team system_woke
