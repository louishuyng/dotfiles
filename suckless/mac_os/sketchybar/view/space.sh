#!/usr/bin/env bash
#
SPACE_ICONS=("Code" "Web" "Chat" "Plan" "BSP" "6" "7")

YELLOW=#eed49f
GREEN=#8DC583
PURPLE=#c6a0f6
GRAY=#868686

DEACTIVATE=$GRAY

sid=0
for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))

  if [ $sid -eq 1 ]; then
    ACTIVATE=$GREEN
  elif [ $sid -eq 6 ] || [ $sid -eq 7 ]; then
    ACTIVATE=$YELLOW
  else
    ACTIVATE=$PURPLE
  fi

  sketchybar --add space space.$sid left                                \
             --set space.$sid associated_space=$sid                     \
                              ignore_association=on                     \
                              icon=${SPACE_ICONS[i]}                    \
                              icon.font="$LABEL:SemiBold:13"            \
                              icon.padding_left=7                      \
                              icon.padding_right=7                     \
                              icon.color=0xff${DEACTIVATE:1}       \
                              icon.highlight_color=0xff${ACTIVATE:1}       \
                              label.drawing=off                         \
                              script="$PLUGIN_DIR/space.sh"             \
                              click_script="yabai -m space --focus $sid"
done
