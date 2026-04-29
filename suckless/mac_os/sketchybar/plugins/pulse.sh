#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# Accent colors and matching animation curves
COLORS=($GREEN $PURPLE $AMBER $CYAN $MAGENTA $RED_SOFT)
ANIMS=(sin exp tanh circ quadratic linear)

# Rotate through colors each tick (update_freq=2 → new color every 2s)
COUNTER_FILE="/tmp/sketchybar_pulse_idx"
IDX=0
[[ -f "$COUNTER_FILE" ]] && IDX=$(cat "$COUNTER_FILE")
NEXT=$(( (IDX + 1) % ${#COLORS[@]} ))
echo "$NEXT" > "$COUNTER_FILE"

COLOR=${COLORS[$IDX]}
ANIM=${ANIMS[$IDX]}

# Two-phase pulse: ramp up to accent color → fade back to dim
sketchybar --animate $ANIM 30 --set pulse label.color=$COLOR \
           --animate $ANIM 50 --set pulse label.color=$ICON_DIM
