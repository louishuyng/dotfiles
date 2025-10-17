#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get current time and date
TIME=$(date '+%H:%M')
DATE=$(date '+%b-%d')

# Format the label with both time and date
LABEL="$TIME $DATE"

# Set the clock with enhanced styling
sketchybar --set "$NAME" label="$LABEL" \
                        icon="󰅐" \
                        icon.color=$YELLOW \
                        label.color=$WHITE \
