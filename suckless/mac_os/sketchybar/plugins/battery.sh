#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ -z "$PERCENTAGE" ]]; then
    exit 0
fi

if [[ $CHARGING != "" ]]; then
    SUFFIX=" ⚡"
else
    SUFFIX=""
fi

# Bright colors — all easily readable
if    [[ $PERCENTAGE -le 10 ]]; then COLOR=$RED_SOFT   # red
elif  [[ $PERCENTAGE -le 25 ]]; then COLOR=$AMBER      # amber
elif  [[ $PERCENTAGE -le 50 ]]; then COLOR=$AMBER      # amber
elif  [[ $PERCENTAGE -le 75 ]]; then COLOR=$GREEN      # green
else                                  COLOR=$GREEN      # green
fi

sketchybar --animate tanh 20 \
    --set "$NAME" \
        icon.color="$COLOR" \
        label="B:${PERCENTAGE}%${SUFFIX}" \
        label.color="$COLOR"
