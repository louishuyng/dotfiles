#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Create a popup showing calendar and date info
sketchybar --set clock popup.drawing=toggle

# Check if popup is being shown
if [ "$(sketchybar --query clock | jq -r '.popup.drawing')" = "on" ]; then
    # Get current date info
    FULL_DATE=$(date "+%A, %B %d, %Y")
    WEEK_NUMBER=$(date "+Week %V")
    DAY_OF_YEAR=$(date "+Day %j of %Y")
    
    # Add date information items
    sketchybar --add item clock.full_date popup.clock \
               --set clock.full_date icon="󰸘" \
                                   icon.color=$YELLOW \
                                   label="$FULL_DATE" \
                                   click_script="open /System/Applications/Calendar.app; sketchybar --set clock popup.drawing=off"
    
    sketchybar --add item clock.week popup.clock \
               --set clock.week icon="󰸗" \
                              icon.color=$BLUE \
                              label="$WEEK_NUMBER" \
                              click_script="sketchybar --set clock popup.drawing=off"
    
    sketchybar --add item clock.day_of_year popup.clock \
               --set clock.day_of_year icon="󰸙" \
                                     icon.color=$GREEN \
                                     label="$DAY_OF_YEAR" \
                                     click_script="sketchybar --set clock popup.drawing=off"
    
    sketchybar --add item clock.calendar popup.clock \
               --set clock.calendar icon="󰸝" \
                                  icon.color=$ORANGE \
                                  label="Open Calendar" \
                                  click_script="open /System/Applications/Calendar.app; sketchybar --set clock popup.drawing=off"
else
    # Remove popup items when hiding
    sketchybar --remove clock.full_date clock.week clock.day_of_year clock.calendar
fi 