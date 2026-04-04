#!/opt/homebrew/bin/bash

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

# Truncate to 25 chars
if [[ ${#TRACK} -gt 25 ]]; then
    TRACK="${TRACK:0:25}…"
fi

if [[ "$STATE" == "playing" ]]; then
    COLOR=0xffbb9af7
else
    COLOR=0xff565f89
fi

sketchybar --set spotify \
    drawing=on \
    icon="♫" \
    icon.color="$COLOR" \
    label="$TRACK" \
    label.color="$COLOR"
