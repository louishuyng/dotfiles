#!/usr/bin/env bash

BIG_ICON_FONT="JetbrainsMono Nerd Font Propo:Regular:16"
MED_ICON_FONT="JetbrainsMono Nerd Font Propo:Regular:15"
ICON_FONT="JetbrainsMono Nerd Font Propo:Regular:14"
SPACE_ICONS=("" "Dev" "" "Web" "Read" "Plan" "Chat" "Any")

sketchybar --add event aerospace_workspace_change

LIST_SPACES_INDEX=(I D T W R P C A)

for i in "${!LIST_SPACES_INDEX[@]}"; do
  sid=${LIST_SPACES_INDEX[i]}

  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change \
             --set space.$sid \
                        icon=${SPACE_ICONS[i]}                    \
                        icon.padding_left=5                      \
                        icon.padding_right=5                     \
                        label.drawing=off                         \
                        script="$PLUGIN_DIR/space.sh $sid"             \
                        click_script="aerospace workspace $sid"

  if [ $sid == "I" ]; then
    sketchybar --set space.$sid icon.font="$MED_ICON_FONT"
  fi
done

# sketchybar --add item separator_space left \
#            --set separator_space \
#                  icon.padding_left=7 \
#                  label.padding_left=0 \
#                  icon.font="$ICON_FONT"             \
#                  icon="" \
#                  click_script="open -a 'Mission Control'"
