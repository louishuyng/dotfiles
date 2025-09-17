SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

ICON_FONT="Hack Nerd Font:Regular:16"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
    --add item spotify right \
    --set spotify \
    icon="" \
    icon.font="$ICON_FONT"             \
    label.padding_right=5                             \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify spotify_change mouse.clicked
