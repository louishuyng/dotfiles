#!/bin/zsh

# Retrieve the number of windows using yabai query
local window_count=$(yabai -m query --spaces --space | jq '.windows | length')

if [[ $window_count -eq 1 ]]; then
  yabai -m config left_padding 0
fi
