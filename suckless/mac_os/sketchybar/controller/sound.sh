#!/usr/bin/env sh

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

SOUNDACTIVEICON=􀊨
SOUNDINACTIVEICON=􀊢

PADDING=4

if [[ $VOLUME = "missing value" ]]; then
    sketchybar --set $NAME icon="" label="" \
      icon.padding_left=0 label.padding_left=0 \
      icon.padding_right=0 label.padding_right=0
elif [[ $MUTED != "false" ]]; then
    sketchybar --set $NAME icon=$SOUNDINACTIVEICON label="$VOLUME% |" \
      icon.padding_left=$PADDING label.padding_left=$PADDING \
      icon.padding_right=$PADDING label.padding_right=$PADDING
else
    sketchybar --set $NAME icon=$SOUNDACTIVEICON label="$VOLUME% |" \
      icon.padding_left=$PADDING label.padding_left=$PADDING \
      icon.padding_right=$PADDING label.padding_right=$PADDING
fi
