#!/bin/bash

# W I N D O W  T I T L E 
WINDOW_TITLE=$(/opt/homebrew/bin/yabai -m query --windows --window | jq -r '.title')

if [[ $WINDOW_TITLE = "" ]]; then
  WINDOW_TITLE=$(/opt/homebrew/bin/yabai -m query --windows --window | jq -r '.app')
fi

if [[ ${#WINDOW_TITLE} -gt 30 ]]; then
  WINDOW_TITLE=$(echo "$WINDOW_TITLE" | cut -c 1-30)
  sketchybar -m set title icon "$WINDOW_TITLE"…
  exit 0
fi

sketchybar -m set title icon "$WINDOW_TITLE"
