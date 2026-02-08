#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Toggle popup
sketchybar --set volume popup.drawing=toggle

# Get current volume and mute status
VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null || echo "50")
MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null || echo "false")

# Add mute toggle
if [ "$MUTED" = "true" ]; then
    MUTE_ICON="󰖁"
    MUTE_COLOR=$RED
else
    MUTE_ICON="󰕾"
    MUTE_COLOR=$GREEN
fi

sketchybar --add item volume.mute popup.volume \
           --set volume.mute icon="$MUTE_ICON" \
                           icon.color="$MUTE_COLOR" \
                           label.drawing=off \
                           background.drawing=off \
                           padding_left=8 \
                           padding_right=2 \
                           click_script="osascript -e 'set volume output muted not (output muted of (get volume settings))'"

# Add volume down button
sketchybar --add item volume.down popup.volume \
           --set volume.down icon="−" \
                           icon.color=$POPUP_ICON_COLOR \
                           icon.font="SF Pro:Medium:14.0" \
                           label.drawing=off \
                           background.drawing=off \
                           padding_left=2 \
                           padding_right=2 \
                           click_script="osascript -e 'set volume output volume ((output volume of (get volume settings)) - 5)'"

# Create compact slider bar with 50 segments
SLIDER_BAR=""
FILLED_SEGMENTS=$((VOLUME / 2))

for i in {1..50}; do
    if [ $i -le $FILLED_SEGMENTS ]; then
        SLIDER_BAR="${SLIDER_BAR}█"
    else
        SLIDER_BAR="${SLIDER_BAR}▒"
    fi
done

sketchybar --add item volume.slider popup.volume \
           --set volume.slider icon="$SLIDER_BAR" \
                              icon.color=$ACCENT_PRIMARY \
                              icon.font="SF Pro:Regular:2.0" \
                              label.drawing=off \
                              background.drawing=off \
                              padding_left=2 \
                              padding_right=2 \
                              click_script="osascript -e 'set volume output volume 50'"

# Add volume up button
sketchybar --add item volume.up popup.volume \
           --set volume.up icon="+" \
                         icon.color=$POPUP_ICON_COLOR \
                         icon.font="SF Pro:Medium:14.0" \
                         label.drawing=off \
                         background.drawing=off \
                         padding_left=2 \
                         padding_right=2 \
                         click_script="osascript -e 'set volume output volume ((output volume of (get volume settings)) + 5)'"

# Add volume percentage
sketchybar --add item volume.percent popup.volume \
           --set volume.percent icon="$VOLUME%" \
                               icon.color=$POPUP_ICON_COLOR \
                               icon.font="SF Pro:Medium:9.0" \
                               label.drawing=off \
                               background.drawing=off \
                               padding_left=2
