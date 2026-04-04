#!/opt/homebrew/bin/bash

CACHE="/tmp/sketchybar_net"
IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')

if [[ -z "$IFACE" ]]; then
    sketchybar --set "$NAME" label="⋮--"
    exit 0
fi

NOW=$(date +%s)
BYTES_IN=$(netstat -ib 2>/dev/null | awk -v iface="$IFACE" '$1==iface{print $7; exit}')
BYTES_OUT=$(netstat -ib 2>/dev/null | awk -v iface="$IFACE" '$1==iface{print $10; exit}')

PREV=$(cat "$CACHE" 2>/dev/null)
PREV_TIME=$(echo "$PREV" | awk '{print $1}')
PREV_IN=$(echo "$PREV" | awk '{print $2}')
PREV_OUT=$(echo "$PREV" | awk '{print $3}')

echo "$NOW $BYTES_IN $BYTES_OUT" > "$CACHE"

format_speed() {
    local bytes=$1
    if   [[ $bytes -ge 1048576 ]]; then printf "%.1fM" "$(echo "scale=1; $bytes/1048576" | bc)"
    elif [[ $bytes -ge 1024 ]];    then printf "%.0fK" "$(echo "scale=0; $bytes/1024" | bc)"
    else printf "${bytes}B"
    fi
}

if [[ -n "$PREV_TIME" && "$PREV_TIME" -gt 0 ]]; then
    ELAPSED=$((NOW - PREV_TIME))
    if [[ $ELAPSED -gt 0 && -n "$BYTES_IN" && -n "$PREV_IN" ]]; then
        SPEED_IN=$(( (BYTES_IN - PREV_IN) / ELAPSED ))
        SPEED_OUT=$(( (BYTES_OUT - PREV_OUT) / ELAPSED ))
        [[ $SPEED_IN -lt 0 ]] && SPEED_IN=0
        [[ $SPEED_OUT -lt 0 ]] && SPEED_OUT=0
        UP=$(format_speed $SPEED_OUT)
        DOWN=$(format_speed $SPEED_IN)
        sketchybar --set "$NAME" label="W⋮ ↑${UP} ↓${DOWN}"
        exit 0
    fi
fi

sketchybar --set "$NAME" label="⋮--"
