!/usr/bin/env sh

ICON_FONT="Hack Nerd Font:Regular:16"
sketchybar --add       event              input_change 'AppleSelectedInputSourcesChangedNotification' \
           --add       item               keyboard right                                              \
           --set       keyboard           script="$PLUGIN_DIR/keyboard.sh"                            \
                                          label.padding_left=0                           \
                                          icon.font="$ICON_FONT"             \
                                          icon="󰘵"                                 \
           --subscribe keyboard           input_change

