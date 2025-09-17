#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Get next calendar event
get_next_event() {
    # Use EventKit to get calendar events
    local event_info=$(osascript << 'EOF'
tell application "Calendar"
    set currentDate to current date
    set endOfDay to currentDate + (1 * days)
    
    set allEvents to {}
    repeat with cal in calendars
        set calEvents to (events of cal whose start date ≥ currentDate and start date ≤ endOfDay)
        set allEvents to allEvents & calEvents
    end repeat
    
    if (count of allEvents) > 0 then
        set nextEvent to item 1 of allEvents
        set eventStart to start date of nextEvent
        set eventTitle to summary of nextEvent
        
        # Find the earliest upcoming event
        repeat with evt in allEvents
            if start date of evt < eventStart and start date of evt ≥ currentDate then
                set nextEvent to evt
                set eventStart to start date of evt
                set eventTitle to summary of evt
            end if
        end repeat
        
        # Format the time properly
        set eventHour to hours of eventStart
        set eventMinute to minutes of eventStart
        
        # Convert to 12-hour format
        if eventHour = 0 then
            set displayHour to 12
            set ampm to "AM"
        else if eventHour < 12 then
            set displayHour to eventHour
            set ampm to "AM"
        else if eventHour = 12 then
            set displayHour to 12
            set ampm to "PM"
        else
            set displayHour to eventHour - 12
            set ampm to "PM"
        end if
        
        # Format minutes with leading zero if needed
        if eventMinute < 10 then
            set minuteStr to "0" & eventMinute
        else
            set minuteStr to eventMinute as string
        end if
        
        set formattedTime to displayHour & ":" & minuteStr & " " & ampm
        
        set eventDate to date string of eventStart
        set todayDate to date string of currentDate
        
        if eventDate = todayDate then
            return eventTitle & "|" & formattedTime
        else
            return eventTitle & "|Tomorrow " & formattedTime
        end if
    else
        return "No events"
    end if
end tell
EOF
)
    
    echo "$event_info"
}

# Get calendar information
EVENT_INFO=$(get_next_event 2>/dev/null)

if [[ "$EVENT_INFO" == "No events" ]] || [[ -z "$EVENT_INFO" ]]; then
    # No upcoming events
    ICON="󰸗"
    COLOR=$GREY
    LABEL="No Events"
else
    # Parse event information
    IFS='|' read -r event_title event_time <<< "$EVENT_INFO"
    
    # Set icon and color based on time
    if [[ "$event_time" == "Tomorrow"* ]]; then
        ICON="󰸗"
        COLOR=$ACCENT_QUATERNARY
    else
        ICON="󰃭"
        COLOR=$ACCENT_PRIMARY
    fi
    
    # Truncate long event titles
    if [[ ${#event_title} -gt 15 ]]; then
        event_title="${event_title:0:15}..."
    fi
    
    # Create multi-line label using actual newline
    LABEL="$event_title
$event_time"
fi

# Update the Calendar item
sketchybar --set "$NAME" icon="$ICON" \
                        icon.color="$COLOR" \
                        label="$LABEL" \
                        label.color=$WHITE \
                        label.font="SF Pro:Medium:12.0" \
                        label.max_chars=20 \
                        click_script="open -a 'Calendar'"
