#!/usr/bin/env bash

SPACE_ICONS=("infra" "code" "terminal" "browser" "note" "work" "reading" "music" "any")

sketchybar --add event aerospace_workspace_change

DEACTIVATE=#868686
ACTIVATE=#AF87D7

LIST_SPACES_INDEX=(I C T B N W R M A)

for i in "${!LIST_SPACES_INDEX[@]}"; do
  sid=${LIST_SPACES_INDEX[i]}

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
