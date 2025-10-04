#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    sketchybar --set "$NAME" \
               icon.color=$GREY \
               label="N/A" \
               icon.padding_right=5 \
               label.padding_left=2 \
               label.padding_right=8 \
               label.drawing=on
    exit 0
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    sketchybar --set "$NAME" \
               icon.color=$GREY \
               label="Auth" \
               icon.padding_right=5 \
               label.padding_left=2 \
               label.padding_right=8 \
               label.drawing=on
    exit 0
fi

# Get notification count (only mention or review_requested)
NOTIFICATION_COUNT=$(gh api notifications --jq '[.[]] | length' 2>/dev/null)

# Handle API errors
if [ $? -ne 0 ] || [ -z "$NOTIFICATION_COUNT" ]; then
    sketchybar --set "$NAME" \
               icon.color=$GREY \
               label="Err" \
               icon.padding_right=5 \
               label.padding_left=2 \
               label.padding_right=8 \
               label.drawing=on
    exit 0
fi

# Update icon and label based on notification count
if [ "$NOTIFICATION_COUNT" -eq 0 ]; then
    sketchybar --set "$NAME" \
               icon.color=$GREY \
               label="" \
               icon.padding_right=8 \
               label.padding_left=0 \
               label.padding_right=0 \
               label.drawing=off
else
    sketchybar --set "$NAME" \
               icon.color=$ORANGE \
               label="$NOTIFICATION_COUNT" \
               icon.padding_right=5 \
               label.padding_left=2 \
               label.padding_right=8 \
               label.drawing=on
fi
