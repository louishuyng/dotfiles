#!/opt/homebrew/bin/bash

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

# Tokyo Night color scale — bg darkens, text stays white
if    [[ $PERCENTAGE -le 10 ]]; then BG=0xff3d0a12; COLOR=0xfff7768e  # red
elif  [[ $PERCENTAGE -le 25 ]]; then BG=0xff3d2000; COLOR=0xffff9e64  # orange
elif  [[ $PERCENTAGE -le 50 ]]; then BG=0xff3d3000; COLOR=0xffe0af68  # yellow
elif  [[ $PERCENTAGE -le 75 ]]; then BG=0xff0f1f3d; COLOR=0xff7aa2f7  # blue
else                                  BG=0xff0f2a12; COLOR=0xff9ece6a  # green
fi

sketchybar --set "$NAME" \
    icon.color="$COLOR" \
    label="B:${PERCENTAGE}%${SUFFIX}" \
    label.color="$COLOR" \
    # background.color="$BG"
