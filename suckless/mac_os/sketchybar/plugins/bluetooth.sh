#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Multiple methods to detect Bluetooth status
BT_ENABLED=false
AIRPODS_CONNECTED=false

# Method 1: Check using defaults (most reliable)
BT_STATE=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
if [[ "$BT_STATE" == "1" ]]; then
    BT_ENABLED=true
fi

# Method 2: Check using system_profiler with better parsing
if [[ "$BT_ENABLED" == false ]]; then
    BT_POWER=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -i "state" | grep -i "on")
    if [[ -n "$BT_POWER" ]]; then
        BT_ENABLED=true
    fi
fi

# Method 3: Check if blueutil is available and use it (most accurate)
if command -v blueutil &> /dev/null; then
    BT_UTIL_STATE=$(blueutil -p 2>/dev/null)
    if [[ "$BT_UTIL_STATE" == "1" ]]; then
        BT_ENABLED=true
    elif [[ "$BT_UTIL_STATE" == "0" ]]; then
        BT_ENABLED=false
    fi
fi

# Method 4: Check if any Bluetooth devices are connected as fallback
if [[ "$BT_ENABLED" == false ]]; then
    BT_DEVICES=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -i "connected: yes")
    if [[ -n "$BT_DEVICES" ]]; then
        BT_ENABLED=true
    fi
fi

# Check specifically for AirPods connection
if [[ "$BT_ENABLED" == true ]]; then
    # Method 1: Check for AirPods in connected devices (SPBluetoothDataType)
    AIRPODS_CHECK=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -i -A 10 -B 2 "airpods\|air pods")
    if [[ -n "$AIRPODS_CHECK" ]]; then
        # Check if AirPods are actually connected (not just paired)
        AIRPODS_CONNECTED_CHECK=$(echo "$AIRPODS_CHECK" | grep -i "connected: yes")
        if [[ -n "$AIRPODS_CONNECTED_CHECK" ]]; then
            AIRPODS_CONNECTED=true
        fi
    fi
    
    # Method 2: Check if AirPods are active audio device (more reliable)
    if [[ "$AIRPODS_CONNECTED" == false ]]; then
        AIRPODS_AUDIO_CHECK=$(system_profiler SPAudioDataType 2>/dev/null | grep -i -A 5 -B 5 "airpods")
        if [[ -n "$AIRPODS_AUDIO_CHECK" ]]; then
            # Check if AirPods are set as default output device
            AIRPODS_DEFAULT_OUTPUT=$(echo "$AIRPODS_AUDIO_CHECK" | grep -i "default output device: yes")
            if [[ -n "$AIRPODS_DEFAULT_OUTPUT" ]]; then
                AIRPODS_CONNECTED=true
            fi
        fi
    fi
    
    # Method 3: Alternative check using blueutil if available
    if [[ "$AIRPODS_CONNECTED" == false ]] && command -v blueutil &> /dev/null; then
        CONNECTED_DEVICES=$(blueutil --connected 2>/dev/null)
        if [[ "$CONNECTED_DEVICES" == *"AirPods"* ]] || [[ "$CONNECTED_DEVICES" == *"Air Pods"* ]]; then
            AIRPODS_CONNECTED=true
        fi
    fi
fi

# Set icon and color based on connection status
if [[ "$AIRPODS_CONNECTED" == true ]]; then
    # AirPods connected - AirPods icon in white
    ICON="󰋋"
    COLOR=$ACCENT_PINK
elif [[ "$BT_ENABLED" == true ]]; then
    # Bluetooth enabled but no AirPods - blue Bluetooth icon
    ICON="󰂯"
    COLOR=$ACCENT_PRIMARY  # Blue
else
    # Bluetooth disabled - gray icon
    ICON="󰂲"
    COLOR=$GREY
fi

# Update the Bluetooth item - icon only, no label
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label.drawing=off 
