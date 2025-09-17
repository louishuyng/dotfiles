#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Multiple methods to detect WiFi status
WIFI_CONNECTED=false
WIFI_SSID=""

# Method 1: Check if WiFi interface is up and has IP
WIFI_IP=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
if [[ -n "$WIFI_IP" && "$WIFI_IP" != "127.0.0.1" ]]; then
    # Method 2: Get network name using networksetup
    WIFI_INFO=$(networksetup -getairportnetwork en0 2>/dev/null)
    if [[ "$WIFI_INFO" != *"You are not associated"* ]] && [[ "$WIFI_INFO" != *"not found"* ]]; then
        WIFI_SSID=$(echo "$WIFI_INFO" | sed 's/Current Wi-Fi Network: //')
        WIFI_CONNECTED=true
    fi
fi

# Method 3: Alternative check using system_profiler (slower but more reliable)
if [[ "$WIFI_CONNECTED" == false ]]; then
    WIFI_STATUS=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A 1 "Current Network Information:" | grep "^[[:space:]]*[^:]" | head -1 | xargs)
    if [[ -n "$WIFI_STATUS" && "$WIFI_STATUS" != "" ]]; then
        WIFI_SSID="$WIFI_STATUS"
        WIFI_CONNECTED=true
    fi
fi

# Method 4: Check using scutil (most reliable)
if [[ "$WIFI_CONNECTED" == false ]]; then
    WIFI_CHECK=$(scutil --nc list | grep Connected | head -1)
    if [[ -n "$WIFI_CHECK" ]]; then
        WIFI_CONNECTED=true
        WIFI_SSID="Connected"
    fi
fi

# Set icon and color based on connection status
if [[ "$WIFI_CONNECTED" == true ]]; then
    # WiFi is connected - green icon
    ICON="󰤨"
    COLOR=$ACCENT_SECONDARY  # Green
else
    # WiFi is disconnected - gray icon
    ICON="󰤭"
    COLOR=$GREY
fi

# Update the WiFi item - icon only, no label
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label.drawing=off
