#!/usr/bin/env bash
#
SPACE_ICONS=("Code" "Web" "Chat" "Plan" "BSP")

GRAY=#D8DEE9
MAGENTA=#c6a0f6
YELLOW=#eed49f

sid=0
for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                \
             --set space.$sid associated_space=$sid                     \
                              ignore_association=on                     \
                              icon=${SPACE_ICONS[i]}                    \
                              icon.font="$LABEL:SemiBold:13"            \
                              icon.padding_left=7                      \
                              icon.padding_right=7                     \
                              icon.color=0xff${GRAY:1}       \
                              icon.highlight_color=0xff${MAGENTA:1}       \
                              label.drawing=off                         \
                              script="$PLUGIN_DIR/space.sh"             \
                              click_script="yabai -m space --focus $sid"
done
