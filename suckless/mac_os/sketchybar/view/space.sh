#!/usr/bin/env bash

SPACE_ICONS=("infra" "code" "web" "chat" "notes" "external")

YELLOW=#eed49f
GREEN=#8DC583
PURPLE=#c6a0f6
GRAY=#868686
ORANGE=#FF8564
BLUE=#36ADFF
WHITE=#F9F9F9

DEACTIVATE=$GRAY

sketchybar --add event aerospace_workspace_change

for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))
  echo $sid

  if [ $sid -eq 1 ]; then
    ACTIVATE=$PURPLE
  elif [ $sid -eq 2 ]; then
    ACTIVATE=$GREEN
  elif [ $sid -eq 3 ]; then
    ACTIVATE=$BLUE
  elif [ $sid -eq 4 ]; then
    ACTIVATE=$YELLOW
  elif [ $sid -eq 5 ]; then
    ACTIVATE=$ORANGE
  else
    ACTIVATE=$WHITE
  fi

  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid \
                        icon=${SPACE_ICONS[i]}                    \
                        icon.padding_left=7                      \
                        icon.padding_right=7                     \
                        icon.color=0xff${DEACTIVATE:1}       \
                        icon.highlight_color=0xff${ACTIVATE:1}       \
                        label.drawing=off                         \
                        script="$PLUGIN_DIR/space.sh $sid"             \
                        click_script="aerospace workspace $sid"
done
