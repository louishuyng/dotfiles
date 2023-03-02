#!/usr/bin/env bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7")

sid=0
for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                \
             --set space.$sid associated_space=$sid                     \
                              ignore_association=on                     \
                              icon=${SPACE_ICONS[i]}                    \
                              icon.padding_left=7                      \
                              icon.padding_right=7                     \
                              icon.color=0xff${WHITE:1}                  \
                              icon.highlight_color=0xff${GREEN:1}       \
                              script="$PLUGIN_DIR/space.sh"             \
                              click_script="yabai -m space --focus $sid"
done
#
sketchybar --add item space_separator left                              \
           --set space_separator icon=􀄭                                 \
                                 background.padding_left=0              \
