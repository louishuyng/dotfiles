#!/bin/bash
# Bar display calculation - sourced (by sketchybarrc at start, and by popup_guard.sh when the display setup changes). Sets DID DX DW DUUID NL NR NOTCH_W and writes the cache files
#   Finds the bar display (BAR_DISPLAY, default main) and measures against it. Notch edges come from helper/notch; no notch → the display centre
#   notch_l = right end of the media island (notch left − 5, media.sh) · bar_x0 = that display's left edge (global x) · bar_uuid = lets spaces.sh count only this display's spaces
mkdir -p "$HOME/.cache/sketchybar"
read -r DID DX DW DUUID <<<"$(sketchybar --query displays 2>/dev/null | python3 -c '
import json,sys; ds=json.load(sys.stdin); w=sys.argv[1]
d=next((d for d in ds if (w=="main" and d["frame"]["x"]==0 and d["frame"]["y"]==0) or str(d["arrangement-id"])==w), ds[0])
print(d["DirectDisplayID"], int(d["frame"]["x"]), int(d["frame"]["w"]), "Main" if d["frame"]["x"]==0 and d["frame"]["y"]==0 else d["UUID"])' "${BAR_DISPLAY:-main}" 2>/dev/null)"
read -r NL NR <<<"$("$CONFIG_DIR/helper/notch" $DID 2>/dev/null)"; NL=${NL:-$(( ${DW:-1800} / 2 ))}; NR=${NR:-$NL}
NOTCH_W=$(( NR > NL ? NR - NL : 200 ))
echo $(( NL - 5 )) > "$HOME/.cache/sketchybar/notch_l"; echo ${DX:-0} > "$HOME/.cache/sketchybar/bar_x0"; echo ${DUUID:-Main} > "$HOME/.cache/sketchybar/bar_uuid"
