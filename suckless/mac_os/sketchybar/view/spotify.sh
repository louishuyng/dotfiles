SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
    --add item spotify right \
    --set spotify \
    icon.y_offset=1 \
    icon.font="$LABEL:Bold:20.0" \
    label.drawing=yes \
    label.padding_right=3 \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify spotify_change mouse.clicked
