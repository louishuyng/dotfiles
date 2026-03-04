#!/opt/homebrew/bin/bash

CACHE_DIR="/tmp/sketchybar"
CACHE_FILE="$CACHE_DIR/spotify_cache"
FONT="BlexMono Nerd Font"

mkdir -p "$CACHE_DIR"

# Check if Spotify is running
if ! pgrep -x "Spotify" >/dev/null; then
    sketchybar --set spotify.text drawing=off --set spotify.cover drawing=off
    exit 0
fi

STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
    sketchybar --set spotify.text drawing=off --set spotify.cover drawing=off
    exit 0
fi

TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
ARTWORK=$(osascript -e 'tell application "Spotify" to artwork url of current track as string' 2>/dev/null)

LABEL="$TRACK - $ARTIST"
CURRENT="$TRACK|$ARTIST|$STATE"
COLOR="0xffffffff"

if [[ "$STATE" == "playing" ]]; then
    FONT_STYLE="Regular"
    # Green Spotify color
    COLOR="0xff1BD760"
else
    FONT_STYLE="Regular"
    COLOR="0xffffffff"
fi

# Cache artwork
if [[ -n "$ARTWORK" ]]; then
    ARTWORK_HASH=$(echo "$ARTWORK" | md5)
    ARTWORK_PATH="$CACHE_DIR/$ARTWORK_HASH.jpg"
    if [[ ! -f "$ARTWORK_PATH" ]]; then
        curl -s --max-time 5 "$ARTWORK" -o "$ARTWORK_PATH" 2>/dev/null
    fi
fi

# Check if track changed for animation
PREVIOUS=$(cat "$CACHE_FILE" 2>/dev/null)
if [[ "$CURRENT" != "$PREVIOUS" ]]; then
    echo "$CURRENT" > "$CACHE_FILE"
fi

sketchybar --set spotify.text drawing=on label="$LABEL" label.font="$FONT:$FONT_STYLE:13.0" label.color="$COLOR"

if [[ -f "$ARTWORK_PATH" ]]; then
    sketchybar --set spotify.cover drawing=on background.image="$ARTWORK_PATH"
else
    sketchybar --set spotify.cover drawing=off
fi
