#!/usr/bin/env bash

ICON_FONT="Hack Nerd Font:Regular:16"
SPACE_ICONS=("" "󰇴" "" "󱡓" "" "󰑇" "" "")

sketchybar --add event aerospace_workspace_change

LIST_SPACES_INDEX=(I C T B W R M O)

for i in "${!LIST_SPACES_INDEX[@]}"; do
  sid=${LIST_SPACES_INDEX[i]}

  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid \
                        icon=${SPACE_ICONS[i]}                    \
                        icon.font="$ICON_FONT"             \
                        icon.padding_left=7                      \
                        icon.padding_right=7                     \
                        label.drawing=off                         \
                        script="$PLUGIN_DIR/space.sh $sid"             \
                        click_script="aerospace workspace $sid"
done

sketchybar --add item separator_space left \
           --set separator_space \
                 icon.padding_left=7 \
                 label.padding_left=0 \
                 icon.font="$ICON_FONT"             \
                 icon="" \
                 click_script="open -a 'Mission Control'"
