!/usr/bin/env sh

sketchybar --add       event              input_change 'AppleSelectedInputSourcesChangedNotification' \
           --add       item               keyboard right                                              \
           --set       keyboard           script="$PLUGIN_DIR/keyboard.sh"                            \
                                          label.padding_left=0                           \
                                          icon="􁔕"                                \
           --subscribe keyboard           input_change

