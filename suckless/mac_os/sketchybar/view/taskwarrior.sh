#!/usr/bin/env sh

export COLOR_CYAN=0xff99cc99

sketchybar --add item taskwarrior right \
           --set taskwarrior script="$PLUGIN_DIR/taskwarrior.sh"  \
                             update_freq=120                    \
                             icon="􀼐"                          \
                             icon.color=$COLOR_CYAN             \
                             label.color=$COLOR_CYAN            \
