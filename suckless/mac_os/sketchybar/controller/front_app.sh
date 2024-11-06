#!/usr/bin/env sh

APP_BG_COLOR=#000000
 
source "$HOME/.config/sketchybar/plugins/icon_map_fn.sh"

__icon_map "${INFO}"

# Number of yabai windows in the current space
WINDOWS=$(/opt/homebrew/bin/yabai -m query --windows --space mouse | jq 'length')

if [ "$icon_result" != ":default:" ]; then
  sketchybar --set $NAME label="$INFO " icon="$icon_result"
else
  sketchybar --set $NAME label="$INFO " icon=""
fi

sketchybar --add item space_separator left                              \
           --set space_separator icon=􀑋                                 \
                 space_separator click_script="open -a 'Mission Control'"          \
                                 background.padding_left=0              \
                                 background.color=0xff${APP_BG_COLOR:1} \
                                 label="$WINDOWS"                        \
