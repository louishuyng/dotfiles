#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Create a simple popup menu for the Apple logo
sketchybar --set apple.logo popup.drawing=toggle

# Check if popup is being shown
if [ "$(sketchybar --query apple.logo | jq -r '.popup.drawing')" = "on" ]; then
    # Add popup items
    sketchybar --add item apple.prefs popup.apple.logo \
               --set apple.prefs icon="󰒓" \
                                icon.color=$BLUE \
                                label="System Preferences" \
                                click_script="open /System/Applications/System\ Preferences.app; sketchybar --set apple.logo popup.drawing=off"
    
    sketchybar --add item apple.activity popup.apple.logo \
               --set apple.activity icon="󰖚" \
                                   icon.color=$GREEN \
                                   label="Activity Monitor" \
                                   click_script="open /System/Applications/Utilities/Activity\ Monitor.app; sketchybar --set apple.logo popup.drawing=off"
    
    sketchybar --add item apple.lock popup.apple.logo \
               --set apple.lock icon="󰌾" \
                               icon.color=$RED \
                               label="Lock Screen" \
                               click_script="pmset displaysleepnow; sketchybar --set apple.logo popup.drawing=off"
    
    sketchybar --add item apple.sleep popup.apple.logo \
               --set apple.sleep icon="󰤄" \
                                icon.color=$YELLOW \
                                label="Sleep" \
                                click_script="pmset sleepnow; sketchybar --set apple.logo popup.drawing=off"
else
    # Remove popup items when hiding
    sketchybar --remove apple.prefs apple.activity apple.lock apple.sleep
fi
