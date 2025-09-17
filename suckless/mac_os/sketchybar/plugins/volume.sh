#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get volume information
if [ "$SENDER" = "volume_change" ]; then
    VOLUME="$INFO"
    # Check if muted by trying to get current mute state
    MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null)
else
    VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
    MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null)
fi

# Fallback if osascript fails
if [[ -z "$VOLUME" ]]; then
    VOLUME=50
fi

# Determine icon and color based on volume level and mute status
if [[ $MUTED == "true" ]]; then
    ICON="󰖁"  # Muted icon
    COLOR=$RED
    LABEL=""  # No label for muted state since we're not showing labels
else
    if [[ $VOLUME -gt 75 ]]; then
        ICON="󰕾"  # High volume
        COLOR=$ACCENT_PRIMARY
    elif [[ $VOLUME -gt 50 ]]; then
        ICON="󰖀"  # Medium volume
        COLOR=$ACCENT_PRIMARY
    elif [[ $VOLUME -gt 25 ]]; then
        ICON="󰕿"  # Low volume
        COLOR=$YELLOW
    elif [[ $VOLUME -gt 0 ]]; then
        ICON="󰕿"  # Very low volume
        COLOR=$ORANGE
    else
        ICON="󰖁"  # No volume
        COLOR=$RED
    fi
    LABEL=""  # No label since we're not showing labels in the bar
fi

# Update the volume item
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label="$LABEL"

# Update popup if it's currently showing
if [ "$(sketchybar --query volume | jq -r '.popup.drawing')" = "on" ]; then
    # Update the slider bar
    SLIDER_BAR=""
    FILLED_SEGMENTS=$((VOLUME / 2))
    
    for i in {1..50}; do
        if [ $i -le $FILLED_SEGMENTS ]; then
            SLIDER_BAR="${SLIDER_BAR}█"
        else
            SLIDER_BAR="${SLIDER_BAR}▒"
        fi
    done
    
    # Update mute button
    if [[ $MUTED == "true" ]]; then
        MUTE_ICON="󰖁"
        MUTE_COLOR=$RED
    else
        MUTE_ICON="󰕾"
        MUTE_COLOR=$GREEN
    fi
    
    sketchybar --set volume.mute icon="$MUTE_ICON" icon.color="$MUTE_COLOR"
    sketchybar --set volume.slider icon="$SLIDER_BAR"
    sketchybar --set volume.percent icon="$VOLUME%"
fi
