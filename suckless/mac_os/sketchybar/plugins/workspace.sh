#!/bin/bash

FONT="BlexMono Nerd Font"

# # Random Icon
# ICON_ONE=""
# ICON_TWO=""
# ICON_FOUR=""
#
# ICONS=($ICON_ONE $ICON_TWO $ICON_THREE)
#
# RANDOM_ICON=${ICONS[$RANDOM % ${#ICONS[@]}]}

sketchybar --set $NAME label="$FOCUSED_WORKSPACE |" icon="󱃞" icon.font="$FONT:Regular:18" animate tanh 10
