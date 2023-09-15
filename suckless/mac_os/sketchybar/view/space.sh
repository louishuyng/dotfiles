#!/usr/bin/env bash

SPACE_ICONS=("􀯠" "􀩼" "􀰳" "4" "5")

LABEL="JetBrainsMono Nerd Font Mono"

sid=0
for i in "${!SPACE_ICONS[@]}"; do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                \
             --set space.$sid associated_space=$sid                     \
                              ignore_association=on                     \
                              icon=${SPACE_ICONS[i]}                    \
                              icon.font="$LABEL:SemiBold:13"            \
                              icon.padding_left=10                      \
                              icon.padding_right=10                     \
                              icon.color=0xff${GRAY:1}       \
                              icon.highlight_color=0xff${GREEN:1}       \
                              label.drawing=off                         \
                              script="$PLUGIN_DIR/space.sh"             \
                              click_script="yabai -m space --focus $sid"
done
#
sketchybar --add item space_separator left                              \
           --set space_separator icon=􀄭                                 \
                                 icon.font="$LABEL:SemiBold:13"         \
                                 background.padding_left=0              \
                                 icon.color=0xff${YELLOW:1}             \
