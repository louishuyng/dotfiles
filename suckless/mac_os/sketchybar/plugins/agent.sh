#!/bin/bash
# agent cell (rev 6): [agent  ✳ 40%  ◎ 12%  grok 8%] — claude·codex 5-hour usage, grok weekly pool. Popup AGENTS: 5h·week % · bar · reset
# Values come from plugins/usage.py (Claude: usage API every 5 min via the keychain OAuth token; Codex: ~/.codex/sessions; Grok: Grok Bot weekly reading). Every 15 s (0.03 s). Missing or past-reset values show —
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
CL=0xffd97757   # claude color (design doc)
[ -f "$HOME/.claude.json" ] || [ -d "$HOME/.codex" ] || [ -d "$HOME/Library/Application Support/Grok Bot" ] || [ -d "$HOME/.grok" ] || { sketchybar --set agent drawing=off --set agent.claude drawing=off --set agent.codex drawing=off --set agent.grok drawing=off; exit 0; }
[ -d "$HOME/Library/Application Support/Grok Bot" ] || [ -d "$HOME/.grok" ] || command -v grok >/dev/null || sketchybar --set agent.grok drawing=off
# One line: claude·codex 5h %·reset·week %·reset, then elapsed time % (5h·week)
IFS=$'\t' read -r C5 C5R CW CWR X5 X5R XW XWR C5E CWE X5E XWE GW GWR GWE <<<"$(/usr/bin/python3 "$CONFIG_DIR/plugins/usage.py" 2>/dev/null | /usr/bin/python3 -c '
import json,sys,datetime as D
W="MoTuWeThFrSaSu"
def loc(s):
    try: return D.datetime.fromisoformat(s.replace("Z","+00:00")).astimezone()
    except Exception: return None
def left(s):
    t=loc(s); return (t-D.datetime.now().astimezone()).total_seconds() if t else None
def r5(s):
    t=loc(s); return t.strftime("%H:%M reset") if t else "—"
def rw(s):
    t=loc(s); return t.strftime("%m.%d reset") if t else "—"   # no weekday: same suffix length as the 5h row so the reset text ends on the same line in every row
def el(s,span):   # elapsed time %
    l=left(s); return "—" if l is None else str(int(max(0,min(100,(span-l)/span*100))))
try: d=json.load(sys.stdin)
except Exception: d={}
c={w.get("key"):w for w in d.get("claude",{}).get("windows",[])}
s,w=c.get("session",{}),c.get("weekly_all",{}); x=d.get("codex",{}); g=d.get("grok",{})
v=lambda a: "—" if a is None else str(a)
H5,WK=5*3600,7*86400
print("\t".join([v(s.get("percent")),r5(s.get("resetsAt","")),v(w.get("percent")),rw(w.get("resetsAt","")),
                 v(x.get("five")),r5(x.get("fiveResetsAt","")),v(x.get("week")),rw(x.get("weekResetsAt","")),
                 el(s.get("resetsAt",""),H5),el(w.get("resetsAt",""),WK),el(x.get("fiveResetsAt",""),H5),el(x.get("weekResetsAt",""),WK),
                 v(g.get("week")),rw(g.get("weekResetsAt","")),el(g.get("weekResetsAt",""),WK)]))
' 2>/dev/null)"
col() { case "$1" in (—|"") echo $TEXT3 ;; (*) [ "$1" -ge 95 ] && echo $ERR || { [ "$1" -ge 80 ] && echo $WARN || echo $TEXT; } ;; esac; }
pct() { [ "$1" = — ] || [ -z "$1" ] && echo "—" || echo "$1%"; }
anim_label agent.claude "$(pct "$C5")" label.color=$(col "$C5")
anim_label agent.codex "$(pct "$X5")" label.color=$(col "$X5")
anim_label agent.grok "$(pct "$GW")" label.color=$(col "$GW")

# Popup (rev 5, 17:43): row A = name (5h/week) · value % · reset on the right / row B = 50-cell gauge (2% per cell), height 16
# Gauge = lit cells (icon, agent color) + empty cells (label, --line). Glyph Menlo 9.8pt '▋' → cell 3.8×10 · gap 2.1 (closest to the menu-bar bar's 4×10 · 2, compared across every installed font) · 5.9pt per cell → 50 cells = 294
GAUGE=294   # value start → reset end = gauge length (50 cells). Not the grok percent.
pace() { # <%> <elapsed %> → value color: ≥95 err · ≥80 warn · used more than the time elapsed warn
  case "$1" in (—|"") echo $TEXT3; return ;; esac
  [ "$1" -ge 95 ] && { echo $ERR; return; }; [ "$1" -ge 80 ] && { echo $WARN; return; }
  [ "$2" != — ] && [ "$1" -gt "$2" ] && { echo $WARN; return; }; echo $TEXT; }
lineA() { # <name> <%> <reset> → value and reset share one text cell (a row can't hold two colors) — reset right-aligned to the gauge end
  local v; v=$(pct "$2"); local n=$(( ( (GAUGE - $(perl "$CONFIG_DIR/plugins/width.pl" "$v") - $(perl "$CONFIG_DIR/plugins/width.pl" "$3")) * 10 + 36 ) / 72 ))   # rounded
  [ $n -lt 2 ] && n=2; printf '%s\t%s%*s%s\t' "$1" "$v" "$n" "" "$3"; }
{ claude_hint=""; [ "$C5" = — ] && claude_hint=" · run /usage"
  printf '_\tclaude%s\t%s\t\n' "$claude_hint" "$TEXT"
  printf '%s%s\t\n' "$(lineA 5h "$C5" "$C5R")" "$(pace "$C5" "$C5E")"; printf '_\t.\t\t\n'
  printf '%s%s\t\n' "$(lineA week "$CW" "$CWR")" "$(pace "$CW" "$CWE")"; printf '_\t.\t\t\n'
  printf '_\tcodex\t%s\t\n' "$TEXT"
  printf '%s%s\t\n' "$(lineA 5h "$X5" "$X5R")" "$(pace "$X5" "$X5E")"; printf '_\t.\t\t\n'
  printf '%s%s\t\n' "$(lineA week "$XW" "$XWR")" "$(pace "$XW" "$XWE")"; printf '_\t.\t\t\n'
  printf '_\tgrok\t%s\t\n' "$TEXT"
  printf '%s%s\t\n' "$(lineA week "$GW" "$GWR")" "$(pace "$GW" "$GWE")"; printf '_\t.\t\t\n'
} | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_W=368 popup_rows agent AGENTS
gauge() { # <row index> <color> <%>
  local n=0 i f="" e=""; case "$3" in (—|"") ;; (*) n=$(( ($3 + 1) / 2 )) ;; esac
  for ((i=0;i<50;i++)); do [ $i -lt $n ] && f+="▋" || e+="▋"; done
  # At the boundary between lit cells (icon) and empty cells (label) SketchyBar trims the padding beside the glyph, shrinking the cell gap by 2.5pt → widen by 3 only when both exist (measured from a capture)
  local bp=0; [ -n "$f" ] && [ -n "$e" ] && bp=1
  sketchybar --set agent.p.$1 icon.drawing=on icon="$f" icon.color=$2 icon.width=dynamic icon.padding_left=65 icon.padding_right=0 \
    icon.font="Menlo:Regular:9.8" label="$e" label.color=$LINE label.font="Menlo:Regular:9.8" label.padding_left=$bp label.padding_right=10 \
    background.height=16 2>/dev/null
}
glyph() { sketchybar --set agent.p.$1 icon.drawing=on icon="$2" icon.font="${4:-JetBrainsMono Nerd Font Propo:Regular:14.0}" icon.color=$3 \
  icon.width=64 icon.padding_left=12 label.padding_left=0 2>/dev/null; }
rowA() { sketchybar --set agent.p.$1 icon.width=64 icon.padding_left=12 label.padding_left=0 label.width=dynamic label.align=left 2>/dev/null; }   # value = same start line as the model name and gauge
for k in 1 3 6 8 11; do rowA $k; done
glyph 0 $'\xee\xb2\x82' $CL; gauge 2 $CL "$C5"; gauge 4 $CL "$CW"
glyph 5 $'\xee\xb2\x81' $TEXT; gauge 7 $TEXT "$X5"; gauge 9 $TEXT "$XW"
glyph 10 ":grok_bot:" $TEXT "sketchybar-app-font:Regular:14.0"; gauge 12 $TEXT "$GW"
sketchybar --set agent.p.5 background.height=30 icon.y_offset=-3 label.y_offset=-3 2>/dev/null   # 6 more between agents — row taller and text 3 lower, so the gap lands on top only
sketchybar --set agent.p.10 background.height=30 icon.y_offset=-3 label.y_offset=-3 2>/dev/null
