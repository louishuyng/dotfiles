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

# Single AppleScript call returns: state|track|artist
INFO=$(osascript <<'EOA' 2>/dev/null
tell application "Spotify"
    return (player state as string) & "|" & (name of current track as string) & "|" & (artist of current track as string)
end tell
EOA
)

IFS='|' read -r STATE TRACK ARTIST <<<"$INFO"

if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
    sketchybar --set spotify drawing=off
    exit 0
fi

FULL_LABEL="$TRACK - $ARTIST |"

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
