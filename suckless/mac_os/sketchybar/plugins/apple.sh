#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Create a simple popup menu for the logo
sketchybar --set logo popup.drawing=toggle

sketchybar --add item logo.prefs popup.logo \
           --set logo.prefs icon="󰒓" \
                            icon.color=$BLUE \
                            label="System Preferences" \
                            click_script="open /System/Applications/System\ Settings.app; sketchybar --set logo.logo popup.drawing=off"

sketchybar --add item logo.activity popup.logo \
           --set logo.activity icon="󰖚" \
                               icon.color=$GREEN \
                               label="Activity Monitor" \
                               click_script="open /System/Applications/Utilities/Activity\ Monitor.app; sketchybar --set logo popup.drawing=off"

sketchybar --add item logo.lock popup.logo \
           --set logo.lock icon="󰌾" \
                           icon.color=$RED \
                           label="Lock Screen" \
                           click_script="pmset displaysleepnow; sketchybar --set logo popup.drawing=off"

sketchybar --add item logo.sleep popup.logo \
           --set logo.sleep icon="󰤄" \
                            icon.color=$YELLOW \
                            label="Sleep" \
                            click_script="pmset sleepnow; sketchybar --set logo popup.drawing=off"
