#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Cache file for weather data
CACHE_FILE="/tmp/sketchybar_weather_cache"
CACHE_DURATION=1800  # 30 minutes

# Function to get weather data
get_weather() {
    # You can replace this with your preferred weather API
    # For now, using a simple placeholder
    local location="DaNang"
    
    # Try to get weather from wttr.in (simple text-based weather)
    local weather_data=$(curl -s "wttr.in/$location?format=3" 2>/dev/null)
    
    if [ -n "$weather_data" ]; then
        echo "$weather_data"
    else
        echo "Weather unavailable"
    fi
}

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    cache_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    
    if [ $((current_time - cache_time)) -lt $CACHE_DURATION ]; then
        weather=$(cat "$CACHE_FILE")
    else
        weather=$(get_weather)
        echo "$weather" > "$CACHE_FILE"
    fi
else
    weather=$(get_weather)
    echo "$weather" > "$CACHE_FILE"
fi

# Extract temperature and condition
if [[ "$weather" =~ ([0-9.-]+°[CF]) ]]; then
    temp="${BASH_REMATCH[1]}"
    sketchybar --set "$NAME" label="$temp" \
                            icon.color=$BLUE \
                            label.color=$WHITE
else
    sketchybar --set "$NAME" label="N/A" \
                            icon.color=$GREY \
                            label.color=$GREY
fi
