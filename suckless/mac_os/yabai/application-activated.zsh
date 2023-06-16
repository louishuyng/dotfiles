#!/bin/zsh

# Get all the windows on current space
local WINDOWS_ARRAY=$(yabai -m query --spaces --space \
  | jq -re ".index" \
  | xargs -I{} yabai -m query --windows --space {})

# Stack first instance of Kitty and Vivaldi
local KITTY_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Kitty")) | .[0] | .id')
local VIVALDI_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Vivaldi")) | .[0] | .id')

if [[ $KITTY_ID != 'null' && $VIVALDI_ID != 'null' ]]; then;
  yabai -m window $KITTY_ID --stack $VIVALDI_ID
fi
