#!/usr/bin/env bash

SPACE_ICONS=("IDE" "2" "3" "4")

YELLOW=#eed49f
GREEN=#8DC583
PURPLE=#c6a0f6
GRAY=#868686

DEACTIVATE=$GRAY

sid=0
for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                \
             --set space.$sid associated_space=$sid                     \
                              ignore_association=on                     \
                              icon=${SPACE_ICONS[i]}                    \
                              icon.font="$LABEL:SemiBold:13"            \
                              icon.padding_left=10                      \
                              icon.padding_right=3                     \
                              background.corner_radius=0                \
                              background.highlight_color=0xff1E1D2D         \
                              background.color=0xffCBA6F9         \
                              background.drawing=on                    \
                              icon.highlight_color=0xff250C42       \
                              label.drawing=on                         \
                              script="$PLUGIN_DIR/space.sh"             \
                              click_script="yabai -m space --focus $sid"
done
