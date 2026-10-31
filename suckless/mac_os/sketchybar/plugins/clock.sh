#!/bin/bash
# Clock + calendar popup. Today is shown as [29].
#   Year-month row: the month being viewed, centered; ● at the right end (dim on the current month, bright on another month — click to jump back to this month)
#   ‹ 08 row = previous month, 10 › row = next month (click the row; the popup stays open after the click)
#   Events: everything that touches the viewed month (multi-day shown as 09.23-09.26). All macOS Calendar calendars (holidays shown separately). Over 16 events → '+N more'
# The calendar is prebuilt in the background (every 10 s, redrawn only when changed). Clicks go through popup_click.sh.
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
OFF_FILE="$HOME/.cache/sketchybar/calmonth"
OFF=$(cat "$OFF_FILE" 2>/dev/null || echo 0)
case "$SENDER" in
  cal_step) [ "$CAL_STEP" = 0 ] && OFF=0 || OFF=$((OFF + CAL_STEP)) ;;
  *) [ "$(cat "$POPUP_OPEN" 2>/dev/null)" = clock ] || OFF=0 ;;   # while open, keep the viewed month
esac
echo "$OFF" > "$OFF_FILE"

adj=""; [ "$OFF" -lt 0 ] && adj="-v${OFF}m"; [ "$OFF" -gt 0 ] && adj="-v+${OFF}m"
base=$(date -v1d $adj +%Y-%m-01); first=$(date -j -f %Y-%m-%d "$base" +%w)
days=$((10#$(date -j -v+1m -v-1d -f %Y-%m-%d "$base" +%d)))
prev=$(date -j -v-1m -f %Y-%m-%d "$base" +%m); next=$(date -j -v+1m -f %Y-%m-%d "$base" +%m)
[ "$OFF" = 0 ] && today=$((10#$(date +%d))) || today=0

# Events: everything that touches the viewed month (including multi-day events that started the month before). All macOS Calendar calendars
# helper/events reads Apple Calendar directly (icalBuddy reports the last day of multi-day all-day events one day short). 0.5 s per run, 0.02 s CPU
# Holidays (rev 9): the subscribed holiday calendar named in HOLIDAY_CAL (includes substitute holidays, nothing hard-coded) — names in red in the event list, day numbers in red
#   Kept out of the regular events and read separately so consecutive holidays merge into one row (Chuseok holiday · Chuseok · Chuseok holiday → 09.24-09.26 Chuseok). Reloaded for each month viewed
HC="$HOME/.cache/sketchybar/holiday.cal"; [ -s "$HC" ] || { [ -n "${HOLIDAY_CAL-}" ] && "${CONFIG_DIR}/helper/events" calid "${HOLIDAY_CAL-}" > "$HC" 2>/dev/null; }
HID=$([ -n "${HOLIDAY_CAL-}" ] && cat "$HC" 2>/dev/null)
HRAW=""; [ -n "$HID" ] && HRAW=$("${CONFIG_DIR}/helper/events" "$base" "$HID" 2>/dev/null)
EV=$("${CONFIG_DIR}/helper/events" "$base" 2>/dev/null | grep -vxF -f <(printf '%s\n' "$HRAW"))   # everything, minus the holiday rows
HOL=""; [ -n "$HRAW" ] && HOL=$(python3 -c 'import sys,datetime as D
y=int(sys.argv[1][:4]); rows=[]
for l in sys.stdin:
  if "\t" not in l: continue
  k,n=l.rstrip("\n").split("\t",1); a,_,b=k.partition("-"); b=b or a
  rows.append([a,b,n,n.replace(" 연휴","").strip()])
nd=lambda s:(D.date(y,int(s[:2]),int(s[3:]))+D.timedelta(days=1)).strftime("%m.%d")
out=[]
for r in rows:
  if out and out[-1][3]==r[3] and nd(out[-1][1])==r[0]: out[-1][1]=r[1]
  else: out.append(r[:])
for a,b,n,base in out: print(("%s-%s" % (a,b) if a!=b else a)+"\t"+(base if any(x[3]==base and x[2]!=base for x in rows) and a!=b else n))' "$base" <<<"$HRAW")
HDAYS=$(python3 -c 'import sys,datetime as D
y,m=int(sys.argv[1][:4]),int(sys.argv[1][5:7])
for l in sys.stdin:
  if "\t" not in l: continue
  k=l.split("\t")[0]; a,_,b=k.partition("-"); b=b or a
  d=D.date(y,int(a[:2]),int(a[3:])); e=D.date(y,int(b[:2]),int(b[3:]))
  while d<=e:
    if d.month==m: print(d.day)
    d+=D.timedelta(days=1)' "$base" <<<"$HOL")
MAXEV=16   # popup height cap: over 16 events (24pt×16) → '+N more' — so it fits on a MacBook screen

STEP="@CONFIG_DIR='$CONFIG_DIR' SENDER=cal_step bash '$CONFIG_DIR/plugins/clock.sh'"
CR=$(mktemp -d "${TMPDIR:-/tmp}/calrows.XXXXXX"); trap 'rm -rf "$CR"' EXIT   # per-row color spans (turned into images below). One dir per run — so the 10 s refresh and a month step can't mix
{
  printf '=\t%s\t%s\t%s\n' "$(printf '%32s' '')●" "$TEXT" "${STEP/SENDER=/CAL_STEP=0 SENDER=}"   # the year-month is overlaid below as the icon
  printf '=\t%s\t%s\t%s\n' " ‹ $prev" "$TEXT3" "${STEP/SENDER=/CAL_STEP=-1 SENDER=}"
  printf '=\t%s\t%s\t%s\n' "$(printf '%29s' '')$next ›" "$TEXT3" "${STEP/SENDER=/CAL_STEP=1 SENDER=}"
  printf '=\t%s\t%s\t\n' " SU   MO   TU   WE   TH   FR   SA" "$TEXT3"
  printf '%s\t \n%s\tSU\n%s\t   MO   TU   WE   TH   FR   \n%s\tSA\n' "$TEXT3" "$ERR" "$TEXT3" "$INFO" > "$CR/row3"   # weekday header: SU --err · SA --info
  r=$(printf '%*s' $((first * 5)) ''); sp="$TEXT"$'\t'"$r"$'\n'; row=4
  for ((d = 1; d <= days; d++)); do
    dc=$TEXT; w=$(( (first + d - 1) % 7 )); [ $w = 6 ] && dc=$INFO; { [ $w = 0 ] || grep -qx "$d" <<<"$HDAYS"; } && dc=$ERR   # Sundays and holidays --err (Saturday holidays too) · Saturdays --info
    if [ $d = $today ]; then r+=$(printf '[%2d] ' $d); sp+="$TEXT"$'\t['$'\n'"$dc"$'\t'"$(printf '%2d' $d)"$'\n'"$TEXT"$'\t] \n'   # today's [ ] is --text, only the number takes the weekday color
    else r+=$(printf ' %2d  ' $d); sp+="$TEXT"$'\t \n'"$dc"$'\t'"$(printf '%2d' $d)"$'\n'"$TEXT"$'\t  \n'; fi
    if (( (first + d) % 7 == 0 || d == days )); then printf '=\t%s\t%s\t\n' "${r%"${r##*[![:space:]]}"}" "$TEXT"; printf '%s' "$sp" > "$CR/row$row"; r=""; sp=""; row=$((row + 1)); fi
  done
  n=0; while IFS=$'\t' read -r key what col; do     # "09.23–26<TAB>title<TAB>color" — events + holidays (names --err), by date
    [ -z "$key" ] && continue; n=$((n + 1)); [ $n -gt $MAXEV ] && continue
    printf '%s\t%s\t%s\topen -a Calendar\n' "$key" "$what" "${col:-$TEXT}"
  done < <({ [ -n "$EV" ] && awk -F'\t' -v c="$TEXT" '{print $1"\t"$2"\t"c}' <<<"$EV"; [ -n "$HOL" ] && awk -F'\t' -v c="$ERR" '{print $1"\t"$2"\t"c}' <<<"$HOL"; } | sort -s -t$'\t' -k1,1) | perl "$CONFIG_DIR/plugins/fit.pl" 145   # long titles are cut with … to the width (255 - 98 - 12) / left cell 98 = padding 12 + "09.01-10.01" 11 chars (79) + 7
  n=$(( $(grep -c . <<<"$EV") + $(grep -c . <<<"$HOL") ))
  [ $n -gt $MAXEV ] && printf '_\t+%s more\t%s\topen -a Calendar\n' $((n - MAXEV)) "$TEXT3"
  printf '_\tCalendar ↗\t%s\topen -a Calendar\n' "$TEXT2"
  for ((k = 0; k < 28; k++)); do printf '~\t.\t\t\n'; done   # pad with blank rows to fix the row count (head below): 4 + 6 weeks + 16 + more + link
} | head -n 28 | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' > "$CR/rows"
# Text cells only: space → NBSP (keeps leading spaces). Width 255 = left 5 + 33 chars (5-char cells ×7)×7.2 + right 12 → equal padding of 12 on both sides
# Weekday header and week row colors (rev 9): SketchyBar text has one color per cell, so each row gets an image of colored text (helper/textspans) on top and the real text goes transparent
#   '=' row text starts at 5 → so does the image. Images inside a popup draw 1pt high, hence −1 (measured). Identical content is cached
a=(); for i in 3 4 5 6 7 8 9; do a+=(--set clock.p.$i background.image.drawing=off); done
for f in "$CR"/row[0-9]*; do [ -f "$f" ] || continue; i=${f##*row}
  png="$HOME/.cache/sketchybar/calimg-$(md5 -q "$f").png"; [ -s "$png" ] || "$CONFIG_DIR/helper/textspans" "$png" 12 < "$f"
  a+=(--set clock.p.$i label.color=0x00000000 background.image="$png" background.image.scale=0.5 background.image.drawing=on \
      background.image.padding_left=5 background.image.y_offset=-1)
done
# Year-month row: its color differs from the text (●), so the year-month goes on the icon separately. ● gets label.padding_left 3 — the right edge of its ink lines up with the end of the '›' below (measured 10-07)
DOT=$TEXT3; [ "$OFF" = 0 ] || DOT=$TEXT
a+=(--set clock.p.0 icon.drawing=on icon="$(printf '%13s%s' '' "${base:0:4}.${base:5:2}" | sed $'s/ /\xc2\xa0/g')"
    icon.color=$TEXT icon.width=0 icon.padding_left=5 icon.padding_right=0 label.padding_left=3 label.color=$DOT)
# Row content and decoration (color images · year-month row) go in one command — sent separately, one frame showed in between: the ● jumped and the year-month vanished (seen in a 10-07 recording)
POPUP_XA=("${a[@]}"); POPUP_W=255 POPUP_KW=98 popup_rows clock CALENDAR < "$CR/rows"
sketchybar "${a[@]}" 2>/dev/null   # also when popup_rows skipped because the rows are unchanged (only colors changed)
[ "$SENDER" = cal_step ] || sketchybar --set clock icon="$(date +%m.%d)" label="$(date +%H:%M)"
