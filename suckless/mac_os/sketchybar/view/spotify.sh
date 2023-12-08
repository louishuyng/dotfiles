SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
    --add item spotify right \
    --set spotify \
    icon.font="$LABEL:Bold:22.0" \
    label.drawing=yes \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify spotify_change mouse.clicked
