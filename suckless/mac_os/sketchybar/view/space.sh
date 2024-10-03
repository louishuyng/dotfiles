#!/usr/bin/env bash

SPACE_ICONS=("IDE" "\$internet" "@chat" "workspace" "🎸Chill" )

YELLOW=#eed49f
GREEN=#8DC583
PURPLE=#c6a0f6
GRAY=#868686
ORANGE=#FF8564
BLUE=#AACCD1

DEACTIVATE=$GRAY

for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))

  if [ $sid -eq 1 ]; then
    ACTIVATE=$GREEN
  elif [ $sid -eq 3 ]; then
    ACTIVATE=$YELLOW
  elif [ $sid -eq 4 ]; then
    ACTIVATE=$BLUE
  elif [ $sid -eq 5 ]; then
    ACTIVATE=$ORANGE
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
