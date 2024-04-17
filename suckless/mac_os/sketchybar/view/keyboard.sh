!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"
sketchybar --add       event              input_change 'AppleSelectedInputSourcesChangedNotification' \
           --add       item               keyboard right                                              \
           --set       keyboard           script="$PLUGIN_DIR/keyboard.sh"                            \
                                          label.padding_left=0                           \
                                          icon.font="$ICON_FONT:Regular:13"                 \
                                          icon=":keyboard_maestro:"                                 \
           --subscribe keyboard           input_change

