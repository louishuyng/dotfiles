#!/opt/homebrew/bin/bash

CACHE="/tmp/sketchybar_net"
IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')

if [[ -z "$IFACE" ]]; then
    sketchybar --set "$NAME" label="⋮--"
    exit 0
fi

NOW=$(date +%s)
read BYTES_IN BYTES_OUT < <(netstat -ib 2>/dev/null | awk -v iface="$IFACE" '$1==iface{print $7, $10; exit}')

PREV=$(cat "$CACHE" 2>/dev/null)
read PREV_TIME PREV_IN PREV_OUT <<<"$PREV"

echo "$NOW $BYTES_IN $BYTES_OUT" > "$CACHE"

format_speed() {
    local bytes=$1
    if (( bytes >= 1048576 )); then
        local m_int=$(( bytes / 1048576 ))
        local m_dec=$(( (bytes * 10 / 1048576) % 10 ))
        printf "%d.%dM" "$m_int" "$m_dec"
    elif (( bytes >= 1024 )); then
        printf "%dK" $(( bytes / 1024 ))
    else
        printf "%dB" "$bytes"
    fi
}

if [[ -n "$PREV_TIME" && "$PREV_TIME" -gt 0 ]]; then
    ELAPSED=$((NOW - PREV_TIME))
    if (( ELAPSED > 0 )) && [[ -n "$BYTES_IN" && -n "$PREV_IN" ]]; then
        SPEED_IN=$(( (BYTES_IN - PREV_IN) / ELAPSED ))
        SPEED_OUT=$(( (BYTES_OUT - PREV_OUT) / ELAPSED ))
        (( SPEED_IN < 0 )) && SPEED_IN=0
        (( SPEED_OUT < 0 )) && SPEED_OUT=0
        UP=$(format_speed $SPEED_OUT)
        DOWN=$(format_speed $SPEED_IN)
        sketchybar --set "$NAME" label="󰒍 ↑${UP} ↓${DOWN} |"
        exit 0
    fi
fi

sketchybar --set "$NAME" label="⋮-- |"
