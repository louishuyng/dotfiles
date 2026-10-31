#!/bin/bash
# Volume popup slider: sets the volume to the clicked or dragged position (PERCENTAGE). Only when the user pressed the slider (mouse.clicked)
# The island gauge updates at once without waiting for the system volume_change (vol.sh fast path)
[ "$SENDER" = mouse.clicked ] && [ -n "$PERCENTAGE" ] || exit 0
SENDER=volume_change INFO=$PERCENTAGE bash "$CONFIG_DIR/plugins/vol.sh" &
osascript -e "set volume output volume $PERCENTAGE"
