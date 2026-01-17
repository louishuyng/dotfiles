#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get CPU usage percentage
CPU_USAGE=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d'%' -f1)

# Handle empty CPU usage
if [[ -z "$CPU_USAGE" ]]; then
    CPU_USAGE=0
fi

# Remove decimal point for comparison
CPU_INT=${CPU_USAGE%.*}

# Set icon and color based on CPU usage
if [[ $CPU_INT -le 25 ]]; then
    ICON="󰍛"  # Low CPU
    COLOR=$ACCENT_SECONDARY  # Green
elif [[ $CPU_INT -le 50 ]]; then
    ICON="󰍜"  # Medium CPU
    COLOR=$ACCENT_PRIMARY  # Blue
elif [[ $CPU_INT -le 75 ]]; then
    ICON="󰍝"  # High CPU
    COLOR=$ACCENT_TERTIARY  # Orange
else
    ICON="󰍞"  # Very High CPU
    COLOR=$RED  # Red
fi

# Update the CPU item
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label="$CPU_USAGE%" \
