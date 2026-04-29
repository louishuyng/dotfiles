#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

BATT=$(pmset -g batt)
[[ "$BATT" =~ ([0-9]+)% ]] && PERCENTAGE="${BASH_REMATCH[1]}" || PERCENTAGE=""
[[ "$BATT" == *"AC Power"* ]] && SUFFIX=" ⚡" || SUFFIX=""

if [[ -z "$PERCENTAGE" ]]; then
    exit 0
fi

if    [[ $PERCENTAGE -le 10 ]]; then COLOR=$RED_SOFT
elif  [[ $PERCENTAGE -le 50 ]]; then COLOR=$AMBER
else                                  COLOR=$GREEN
fi

sketchybar --animate tanh 20 \
    --set "$NAME" \
        icon.color="$COLOR" \
        label="B:${PERCENTAGE}%${SUFFIX} |" \
        label.color="$COLOR"
