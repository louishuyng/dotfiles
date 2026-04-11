#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

STATE_FILE="/tmp/sketchybar_separator"
FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
COLORS=($GREEN $GREEN $CYAN $CYAN $PURPLE $PURPLE $AMBER $AMBER $GREEN $GREEN)

IDX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
CHAR="${FRAMES[$IDX]}"
COLOR="${COLORS[$IDX]}"

sketchybar --animate quadratic 8 \
	--set separator label="$CHAR" label.color="$COLOR"

IDX=$(( (IDX + 1) % ${#FRAMES[@]} ))
echo "$IDX" > "$STATE_FILE"
