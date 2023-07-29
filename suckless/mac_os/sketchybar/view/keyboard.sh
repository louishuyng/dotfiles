!/usr/bin/env sh

sketchybar --add       event              input_change 'AppleSelectedInputSourcesChangedNotification' \
           --add       item               keyboard right                                              \
           --set       keyboard           script="$PLUGIN_DIR/keyboard.sh"                            \
                                          icon="􁔕"                                \
           --subscribe keyboard           input_change

