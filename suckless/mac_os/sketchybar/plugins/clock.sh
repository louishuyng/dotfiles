#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get current time and date
TIME=$(date "+%I:%M %p")
DATE=$(date "+%a %d %b")

# Format the label with both time and date
LABEL="$TIME  $DATE"

# Set the clock with enhanced styling
sketchybar --set "$NAME" label="$LABEL" \
                        icon="󰅐" \
                        icon.color=$YELLOW \
                        label.color=$WHITE \
                        label.font="SF Pro:Medium:13.0"

