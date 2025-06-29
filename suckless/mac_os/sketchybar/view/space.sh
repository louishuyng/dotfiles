#!/usr/bin/env bash

BIG_ICON_FONT="Hack Nerd Font:Regular:16"
MED_ICON_FONT="Hack Nerd Font:Regular:14"
ICON_FONT="Hack Nerd Font:Regular:13"
SPACE_ICONS=("" "Dev" "" "Web" "Chat" "" "Any")

sketchybar --add event aerospace_workspace_change

LIST_SPACES_INDEX=(I D T W C O A)

for i in "${!LIST_SPACES_INDEX[@]}"; do
  sid=${LIST_SPACES_INDEX[i]}

  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid \
                        icon=${SPACE_ICONS[i]}                    \
                        icon.padding_left=5                      \
                        icon.padding_right=5                     \
                        label.drawing=off                         \
                        icon.font.style="Bold"  \
                        script="$PLUGIN_DIR/space.sh $sid"             \
                        click_script="aerospace workspace $sid"

  if [ $sid == "T" ]; then
    sketchybar --set space.$sid icon.font="$MED_ICON_FONT" icon.font.style="Bold"
  fi

  if [ $sid == "O" ]; then
    sketchybar --set space.$sid icon.font="$ICON_FONT" icon.font.style="Bold"
  fi

  if [ $sid == "I" ]; then
    sketchybar --set space.$sid icon.font="$BIG_ICON_FONT" icon.font.style="Bold"
  fi

  # if [ $sid == "A" ] || [ $sid == "C" ] || [ $sid == "O" ]; then
  #   sketchybar --set space.$sid icon.font="$BIG_ICON_FONT"
  # elif [ $sid == "I" ]; then
  #   sketchybar --set space.$sid icon.font="$ICON_SMALL_FRONT"
  # else
  #   sketchybar --set space.$sid icon.font="$ICON_FONT"
  # fi
done

# sketchybar --add item separator_space left \
#            --set separator_space \
#                  icon.padding_left=7 \
#                  label.padding_left=0 \
#                  icon.font="$ICON_FONT"             \
#                  icon="" \
#                  click_script="open -a 'Mission Control'"
