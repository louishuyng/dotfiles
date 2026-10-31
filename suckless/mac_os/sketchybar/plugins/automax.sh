#!/bin/bash
# Maximize newly opened windows with Rectangle (window gap 5). To turn off: AUTOMAX=0 in config.sh, then sketchybar --reload
source "$CONFIG_DIR/config.sh"
[ "${AUTOMAX:-1}" = 1 ] || exit 0
sleep 0.3   # after the window has settled
[ "$("$CONFIG_DIR/helper/newwin" "$AUTOMAX_EXCLUDE" "$AUTOMAX_INCLUDE")" = max ] && open -g "rectangle://execute-action?name=maximize"
