#!/opt/homebrew/bin/bash

SPOTIFY_CACHE="/tmp/sketchybar_spotify_cache"

# Hover: show full track name and artist
if [[ "$SENDER" == "mouse.entered" ]]; then
    if [[ -f "$SPOTIFY_CACHE" ]]; then
        source "$SPOTIFY_CACHE"
        sketchybar --set spotify label="$FULL_LABEL"
    fi
    exit 0
fi

# Hover exit: revert to truncated label
if [[ "$SENDER" == "mouse.exited" ]]; then
    if [[ -f "$SPOTIFY_CACHE" ]]; then
        source "$SPOTIFY_CACHE"
        sketchybar --set spotify label="$SHORT_LABEL"
    fi
    exit 0
fi

if ! pgrep -x "Spotify" >/dev/null; then
    sketchybar --set spotify drawing=off
    exit 0
fi

STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
    sketchybar --set spotify drawing=off
    exit 0
fi

TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)

FULL_LABEL="$TRACK - $ARTIST |"

# Truncate to 25 chars
if [[ ${#TRACK} -gt 25 ]]; then
    SHORT_LABEL="${TRACK:0:25}... |"
else
    SHORT_LABEL="$TRACK |"
fi

if [[ "$STATE" == "playing" ]]; then
    COLOR=0xff1DD05D
else
    COLOR=0xff8A91AD
fi

# Cache for hover events
cat > "$SPOTIFY_CACHE" <<EOC
FULL_LABEL="$FULL_LABEL"
SHORT_LABEL="$SHORT_LABEL"
EOC

sketchybar --set spotify \
    drawing=on \
    icon="󰼛" \
    icon.color="$COLOR" \
    label="$SHORT_LABEL" \
    label.color="$COLOR"
