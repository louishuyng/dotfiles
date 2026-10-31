#!/bin/bash
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
now() {
  for app in Spotify Music; do
    [ "$(osascript -e "application \"$app\" is running")" = "true" ] || continue
    s=$(osascript -e "tell application \"$app\" to if player state is playing then return (name of current track) & \"\t\" & (artist of current track)" 2>/dev/null)
    [ -n "$s" ] && { printf '%s\t%s\n' "$app" "$s"; return; }
  done
}
IFS=$'\t' read -r APP TRACK ARTIST <<<"$(now)"
if [ -z "$TRACK" ]; then sketchybar --set music drawing=off; exit 0; fi
printf 'artist\t%s\t%s\t\n⏮\tprev\t%s\t%s\n⏯\tpause\t%s\t%s\n⏭\tnext\t%s\t%s\n' \
  "$ARTIST" "$TEXT2" \
  "$TEXT" "osascript -e 'tell application \"$APP\" to previous track'" \
  "$TEXT" "osascript -e 'tell application \"$APP\" to playpause'" \
  "$TEXT" "osascript -e 'tell application \"$APP\" to next track'" | popup_rows music MUSIC
sketchybar --set music drawing=on label="$TRACK"
