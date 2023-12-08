#!/usr/bin/env sh

export BLUE=0xff81a2be

sketchybar --add item mail left \
           --set mail script="$PLUGIN_DIR/mail.sh"  \
                             update_freq=60                    \
                             icon="􀍖"                         \
                             icon.color=$BLUE             \
                             label.color=$BLUE            \
