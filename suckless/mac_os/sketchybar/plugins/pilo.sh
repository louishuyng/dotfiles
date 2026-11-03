#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"
# pilo circle - live agents in herdr as a round face with two arms: pose, expression and color. Popup AGENTS: character · agent · project · state per session
# Data: herdr-core terminals with an agent status (hc ls / hc get), at once on agent_status_change (sent by agent_watch.sh) + every 30s
# States: blocked (approval prompt open) · running (working, changed in the last 10 min) · stalled (still "working" but unchanged for 10+ min) · idle (turn ended) · unbound (no agent)
# The circle shows the most urgent state among all sessions: blocked > stalled > running > idle
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
PX="$HOME/.cache/sketchybar/px"
# A burst of agent_status_change events runs once: only the last one continues, 0.15s after it arrived (earlier ones stop here)
if [ "$SENDER" = agent_status_change ]; then E="$HOME/.cache/sketchybar/pilo_evt"; echo $$ > "$E"; sleep 0.15; [ "$(cat "$E" 2>/dev/null)" = $$ ] || exit 0; fi
[ "${PILO_ISLAND:-1}" = 1 ] || { echo off > "$HOME/.cache/sketchybar/pilo"; sketchybar --set pilo drawing=off --set pilo.ul drawing=off; exit 0; }   # writing "off" also ends pilo_anim.sh
OUT=$(/usr/bin/python3 -c '
import os, sys, time, unicodedata as U
import json, subprocess
def hc(*a):
    try: return json.loads(subprocess.run(["hc", *a, "--json"], capture_output=True, text=True, timeout=3).stdout)
    except Exception: return {}
now = time.time(); A = []
for t in hc("ls").get("terminals", []):
    if not t.get("status"): continue   # shells have no status; agents do
    g = hc("get", t["address"]); st = (g.get("status") or {}).get("state", t["status"])
    app = (g.get("status") or {}).get("app") or t.get("agent") or "agent"
    age = now - g.get("status_ms", now * 1000) / 1000
    if st == "working" and age > 600: st = "stalled"
    A.append(({"claude-code": "claude"}.get(app, app), {"working": "running"}.get(st, st), t.get("cwd", ""), age, t["address"]))
def one(x, n=40):
    o, w = "", 0
    for ch in " ".join(str(x or "").split()):
        w += 2 if U.east_asian_width(ch) in "WF" else 1
        if w > n: return o + "…"
        o += ch
    return o
def ago(s): s = int(s); return f"{s}s" if s < 60 else f"{s // 60}m" if s < 3600 else f"{s // 3600}h"
RANK = ["blocked", "stalled", "running", "idle"]
A = [a for a in A if a[1] in RANK]
if not A:
    print("unbound\t0\t0"); print("none\tno agent running in herdr\tunbound\t"); sys.exit(0)
print(min((a[1] for a in A), key=RANK.index), sum(a[1] == "running" for a in A), sum(a[1] == "blocked" for a in A), sep="\t")
W = {"blocked": "needs approval", "running": "working", "stalled": "no signal", "idle": "idle"}
for agent, st, cwd, age, addr in sorted(A, key=lambda a: (RANK.index(a[1]), a[3])):
    print(agent, one((os.path.basename(cwd.rstrip("/")) or "~") + " · " + W[st] + " " + ago(age)), st, addr, sep="\t")
')
IFS=$'\t' read -r TOP NW NB <<<"$(head -1 <<<"$OUT")"
ST="$HOME/.cache/sketchybar/pilo"   # current state - pilo_anim.sh reads it and swaps frames. On a state change the first frame is drawn here right away
[ "$(cat "$ST" 2>/dev/null)" = "$TOP" ] || { echo "$TOP" > "$ST"; sketchybar --set pilo background.image="$PX/pilo_${TOP}_1.png"; }
sketchybar --set pilo drawing=on --set pilo.ul drawing=on
pgrep -qf '^/bin/bash .*/plugins/pilo_anim.sh$' || (CONFIG_DIR="$CONFIG_DIR" nohup /bin/bash "$CONFIG_DIR/plugins/pilo_anim.sh" >/dev/null 2>&1 &)

# Popup: title carries the number of working sessions. Row = character (row background image, 16×12pt) · agent · project · state · time since last signal. Text color = state color
# Row click: Herdr to the front, showing that agent's terminal
scol() { case "$1" in blocked) echo $ERR ;; stalled) echo $WARN ;; running) echo $TEXT ;; *) echo $TEXT3 ;; esac; }
i=0; a=(); rows=""; sts=""
while IFS=$'\t' read -r name text st addr; do
  click=""; [ "$st" = unbound ] || click="open -b dev.herdr.app; $HOME/.local/bin/herdr-app do agent.focus --terminal $addr"
  rows+="$name"$'\t'"$text"$'\t'"$(scol "$st")"$'\t'"$click"$'\n'
  a+=(--set pilo.ul.p.$i background.image="$PX/pilo_s_${st}_1.png" background.image.scale=0.5 background.image.drawing=on
      background.image.padding_left=12 icon.padding_left=36 icon.color=$TEXT2)
  sts+="$st"$'\n'; i=$((i + 1))
done <<<"$(tail -n +2 <<<"$OUT")"
# Legend: one divider line at the bottom, then the 5 states as face · name · meaning. The faces move like the agent rows (their states are appended to pilo_rows; rows without a face are "-")
pad="icon.drawing=off label.drawing=off background.height=6"; DIV=$((i + 1))
a+=(--set pilo.ul.p.$i $pad --set pilo.ul.p.$DIV $pad background.height=1 background.color=$LINE background.padding_left=12 background.padding_right=12
    --set pilo.ul.p.$((i + 2)) $pad --set pilo.ul.p.$((i + 3)) label.font="$FONT:Bold:11.0" label.color=$TEXT2)
rows+=$'_\t-\t\t\n_\t-\t\t\n_\t-\t\t\n_\tLEGEND\t\t\n'; sts+=$'-\n-\n-\n-\n'; i=$((i + 4))
while IFS='|' read -r st text; do
  rows+="$st"$'\t'"$text"$'\t'"$(scol "$st")"$'\t\n'; sts+="$st"$'\n'
  a+=(--set pilo.ul.p.$i background.image="$PX/pilo_s_${st}_1.png" background.image.scale=0.5 background.image.drawing=on
      background.image.padding_left=12 icon.padding_left=36 icon.color=$TEXT2)
  i=$((i + 1))
done <<'LEGEND'
running|working
blocked|waiting on you - approve in the pane
stalled|looks stuck - no signal for 10+ min
idle|idle - waiting for your prompt
unbound|no session - no agent open in herdr
LEGEND
# Divider width = text width of the longest row (name column 137 + columns × 6.9; the 12 on each side comes from the background padding). An item with no text has zero width, so it is set here
LW=$(printf '%s' "$rows" | perl -CS -Mutf8 -F'\t' -lane '$_ = $F[1]; $w = length($_) + (() = /[\p{EastAsianWidth=W}\p{EastAsianWidth=F}]/g); $m = $w if $w > $m; END { printf "%d", 137 + $m * 6.9 }')
a+=(--set pilo.ul.p.$DIV width=${LW:-400})
printf '%s' "$sts" > "$HOME/.cache/sketchybar/pilo_rows"   # state per row - while the popup is open pilo_anim.sh moves the row faces too
# Popup placement: left edge = left end of the underline (like the other circles). If there is no room on the right, the right edge goes to the underline's right end and the popup grows leftwards:
#   underline left x + max popup width (PW) > display right edge − 5 → right, else left.  PW 500 = 12 padding each side + 137 name column + 48 text columns (7.2 each), rounded up
for _ in 1 2 3; do Q=$(sketchybar --query pilo.ul 2>/dev/null); [ -n "$Q" ] && break; sleep 0.1; done   # the query sometimes comes back empty - ask again
AL=$(printf '%s' "$Q" | PW="${PILO_POPUP_W:-500}" DISP="$(sketchybar --query displays 2>/dev/null)" /usr/bin/python3 -c '
import json, os, sys
try:
    k, r = next(iter(json.load(sys.stdin)["bounding_rects"].items())); x = r["origin"][0]
    f = next(d["frame"] for d in json.loads(os.environ["DISP"]) if d["arrangement-id"] == int(k.split("-")[1]))
    print("right" if x + int(os.environ["PW"]) > f["w"] - 5 else "left")   # item x is relative to the left edge of that display
except Exception: pass')
[ -n "$AL" ] && a+=(--set pilo.ul popup.align=$AL)   # unknown → keep the current alignment
POPUP_XA=("${a[@]}"); printf '%s' "$rows" | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_KW=137 popup_rows pilo.ul "AGENTS$([ "$NB" -gt 0 ] && echo " · $NB waiting")$([ "$NW" -gt 0 ] && echo " · $NW working")"
