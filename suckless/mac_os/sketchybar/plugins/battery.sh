#!/opt/homebrew/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ -z "$PERCENTAGE" ]]; then
    exit 0
fi

CHARGE_FONT_SIZE=15
UNCHARGE_FONT_SIZE=16

# Battery level icon
if [[ $CHARGING != "" ]]; then
    ICON=""
elif [[ $PERCENTAGE -le 10 ]]; then ICON="󰂎"
elif [[ $PERCENTAGE -le 20 ]]; then ICON="󱊡"
elif [[ $PERCENTAGE -le 30 ]]; then ICON="󱊡"
elif [[ $PERCENTAGE -le 40 ]]; then ICON="󰁽"
elif [[ $PERCENTAGE -le 50 ]]; then ICON="󱊢"
elif [[ $PERCENTAGE -le 60 ]]; then ICON="󱊢"
elif [[ $PERCENTAGE -le 70 ]]; then ICON="󱊢"
elif [[ $PERCENTAGE -le 80 ]]; then ICON="󱊢"
elif [[ $PERCENTAGE -le 90 ]]; then ICON="󱊢"
else                                ICON="󱊣"
fi

# Diverse color scale
if    [[ $PERCENTAGE -le 10 ]]; then COLOR=0xffff5555  # red    → critical
elif  [[ $PERCENTAGE -le 25 ]]; then COLOR=0xffffb86c  # orange → low
elif  [[ $PERCENTAGE -le 50 ]]; then COLOR=0xfff1fa8c  # yellow → medium
elif  [[ $PERCENTAGE -le 75 ]]; then COLOR=0xff8be9fd  # blue  → good
else                                  COLOR=0xff50fa7b  # green   → full
fi

LABEL="${PERCENTAGE}%"

FONT_SIZE=$UNCHARGE_FONT_SIZE
if [[ $CHARGING != "" ]]; then
    FONT_SIZE=$CHARGE_FONT_SIZE
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    icon.font="BlexMono Nerd Font:Regular:$FONT_SIZE" \
    label="$LABEL" \
    label.color="$COLOR"
