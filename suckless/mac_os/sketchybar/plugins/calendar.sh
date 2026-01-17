#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get count of today's calendar events
get_event_count() {
    # Use EventKit to count today's calendar events
    local event_count=$(osascript << 'EOF'
tell application "Calendar"
    set currentDate to current date
    set startOfDay to currentDate - (time of currentDate)
    set currentTime to time of currentDate
    set endOfDay to startOfDay + (1 * days) - 1

    set todayEventCount to 0
    repeat with cal in calendars
        set calEvents to (events of cal whose start date ≥ startOfDay and start date ≤ endOfDay)
        set todayEventCount to todayEventCount + (count of calEvents)
    end repeat

    return todayEventCount
end tell
EOF
)

    echo "$event_count"
}

# Get calendar information
EVENT_COUNT=$(get_event_count 2>/dev/null)

# Function to open Calendar app
open_calendar() {
    osascript -e 'tell application "Calendar" to activate'
}

if [[ -z "$EVENT_COUNT" ]] || [[ "$EVENT_COUNT" -eq 0 ]]; then
    # No events today
    ICON="󰸗"
    COLOR=$GREY
    LABEL="0 events"
else
    # Events today
    ICON="󰃭"
    COLOR=$ACCENT_PRIMARY

    if [[ "$EVENT_COUNT" -eq 1 ]]; then
        LABEL="1 event"
    else
        LABEL="$EVENT_COUNT events"
    fi
fi

# Update the Calendar item
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label="$LABEL" \
                        label.color=$WHITE \
                        label.font="SF Pro:Medium:12.0" \
                        label.max_chars=20 \
                        click_script="$CONFIG_DIR/plugins/calendar.sh open"

# Handle open command
if [[ "$1" == "open" ]]; then
    open_calendar
fi
