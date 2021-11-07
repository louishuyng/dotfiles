#!/bin/bash

# Exit if Not in Stack
CURRENT=$(yabai -m query --windows --window | jq '.["stack-index"]')
if [[ $CURRENT -eq 0 ]]; then
  sketchybar -m batch --set stack_indicator \
    label="" \
    drawing=off
  # sketchybar -m set stack_sep drawing off
  exit 0
fi

# Use Numbers in place of Dots if the Stack is greater than 10
# Use a larger font for the unicode dots
LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
if [[ $LAST -gt 10 ]]; then
  sketchybar -m batch --set stack_indicator \
    label_font="Iosevka Nerd Font:Bold:16.0" \
    label=$(printf "[%s/%s]" "$CURRENT" "$LAST") \
    drawing=on
  # sketchybar -m set stack_sep drawing=on
  exit 0
else
  sketchybar -m set stack_indicator label_font "Iosevka Nerd Font:Bold:22.0"
fi

# Create Stack Indicator
declare -a dots=()
for i in $(seq 0 $(expr $LAST - 1))
do  
  # Theme 1
  # if [[ $i -lt $(expr $CURRENT - 1) ]]; then
    # dots+="◖"
  # elif [[ $i -gt $(expr $CURRENT - 1) ]]; then
    # dots+="◗"
  # elif [[ $i -eq $(expr $CURRENT - 1) ]]; then
    # dots+="●"
  # fi
  # Theme 2
  [[ $( expr $CURRENT - 1) -eq $i ]] && dots+="●" || dots+="○"
done

# Display Indicator
# sketchybar -m set stack_sep drawing on
sketchybar -m batch --set stack_indicator \
  label=$(printf "%s" ${dots[@]}) \
  drawing=on
