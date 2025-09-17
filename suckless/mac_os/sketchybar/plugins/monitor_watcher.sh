#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Store current monitor state to detect changes
MONITOR_STATE_FILE="/tmp/aerospace_monitor_state"

# Get current monitor state
CURRENT_MONITORS=$(aerospace list-monitors | awk '{print $1}' | sort | tr '\n' ' ')

# Check if state has changed
if [ -f "$MONITOR_STATE_FILE" ]; then
    PREVIOUS_MONITORS=$(cat "$MONITOR_STATE_FILE")
    if [ "$CURRENT_MONITORS" != "$PREVIOUS_MONITORS" ]; then
        # Monitor configuration changed, update display
        "$CONFIG_DIR/plugins/aerospace_display.sh"
    fi
else
    # First run, create state file
    "$CONFIG_DIR/plugins/aerospace_display.sh"
fi

# Save current state
echo "$CURRENT_MONITORS" > "$MONITOR_STATE_FILE" 