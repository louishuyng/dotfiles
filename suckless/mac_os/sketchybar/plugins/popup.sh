#!/bin/bash
# Shared popup helpers. Sourced by each plugin.
#
# Popup contents are built ahead of time in the background (on periodic refresh). A click only opens and closes (popup_click.sh).
#   popup_rows <parent> <title>   ← lines of "left<TAB>right<TAB>color<TAB>click command" on stdin
#   empty title = no title row. Left "_" = a single-line text row, "=" = a calendar cell row — tab-separated, so it cannot be left blank
#   POPUP_KW=<width> left cell width (default 64)
#   POPUP_MAXC=<chars> cuts the right text of named rows at that length (for fixed-width popups)
#   "~" rows are hidden — with a fixed row count, rows are not re-created when contents change while open (re-creating makes the popup disappear)
#   POPUP_W=<width> fixes the row width — for when SketchyBar measures the text too short and clips it (calendar)
#   underline under the parent cell of the open popup (<parent>.u, rev 6)
#
# The look follows the popup in Sketchybar_dark_light.html (rev 5):
#   title row 11px Bold·text-2 · row height 24 · left cell 52px·text-3 · left/right padding 12 · top/bottom 4

POPUP_PARENTS="cpu.ul pilo.ul bat agent ports ts docker ci media vol.ul cal wifi clock front_app"
POPUP_CACHE="$HOME/.cache/sketchybar"

POPUP_LIB="${BASH_SOURCE[0]}"
POPUP_OPEN="$POPUP_CACHE/popup_open"   # name of the popup open now. Absent = closed
CLICKAWAY="${POPUP_LIB%/plugins/*}/helper/clickaway"   # outside-click detection (runs only while a popup is open)

# The underline item of a circle (<circle>.ul) only shows while its window sits above the circle's. Clicking the circle makes macOS raise
# that window over the underline, so when a popup opens the underline is --move'd to the same place to rebuild the window order (no layout change)
popup_raise() { case "$1" in cpu.ul|pilo.ul) sketchybar --move "$1" after "${1%.ul}" 2>/dev/null ;; esac; }

popup_under() { case "$1" in bat) echo bat.u ;; agent) echo agent.u ;; *) echo "$1" ;; esac; }   # item that draws the underline

popup_close_all() { # [one to keep]
  local a=() p
  # closing the calendar rebuilds it for this month in the background — the next open starts at this month
  [ "$(cat "$POPUP_OPEN" 2>/dev/null)" = clock ] && [ "$1" != clock ] && { rm -f "$POPUP_OPEN"
    (CONFIG_DIR="${POPUP_LIB%/plugins/*}" nohup bash "${POPUP_LIB%/*}/clock.sh" >/dev/null 2>&1 &); }
  for p in $POPUP_PARENTS; do [ "$p" = "$1" ] || { a+=(--set "$p" popup.drawing=off); for u in $(popup_under $p); do a+=(--set $u background.drawing=off); done; }; done
  [ -z "$1" ] && rm -f "$POPUP_OPEN"
  pkill -x clickaway
  sketchybar "${a[@]}" 2>/dev/null
}

popup_toggle() {  # bar item click: close if open; otherwise close the others and open only this one
  if [ "$(cat "$POPUP_OPEN" 2>/dev/null)" = "$1" ]; then popup_close_all; return; fi
  popup_close_all "$1"
  local u b=(); for u in $(popup_under "$1"); do b+=(--set $u background.drawing=on); done
  popup_raise "$1"
  sketchybar --set "$1" popup.drawing=on "${b[@]}"
  echo "$1" > "$POPUP_OPEN"
  [ -x "$CLICKAWAY" ] && (nohup "$CLICKAWAY" "source '$POPUP_LIB'; popup_close_all" >/dev/null 2>&1 &)
}

popup_rows() {
  local p="$1" title="$2" data n old items i=0 k v c click cs a=()
  data=$(cat)
  [ -n "$SB_BOOT" ] && return 0   # at startup (first values in sketchybarrc) no popup rows are built - the --update after the bar shows builds them
  mkdir -p "$POPUP_CACHE"
  n=$(grep -c . <<<"$data")
  # A script from before a reload can leave cached rows that no longer exist.
  items=$(sketchybar --query "$p" 2>/dev/null | python3 -c '
import json, sys
print("\n".join(json.load(sys.stdin).get("popup", {}).get("items", [])))
') || return 0
  old=$(printf '%s\n' "$items" | grep -c .)
  [ "$old" = "$((n + 4))" ] && [ "$title"$'\n'"$data" = "$(cat "$POPUP_CACHE/popup.$p" 2>/dev/null)" ] && return 0

  if [ "$((n + 4))" != "$old" ]; then   # row count changed → rebuild (regex --remove does not work, so remove by name)
    local r=() it   # query the rows attached to the popup now and remove them all (so no old rows remain even without the cache)
    for it in $items; do
      r+=(--remove "$it"); done
    [ ${#r[@]} -gt 0 ] && sketchybar "${r[@]}" >/dev/null 2>&1
    a+=(--add item "$p.p.a" "popup.$p" --add item "$p.p.t" "popup.$p" --add item "$p.p.g" "popup.$p")
    for ((i = 0; i < n; i++)); do a+=(--add item "$p.p.$i" "popup.$p"); done
    a+=(--add item "$p.p.z" "popup.$p")
  fi

  # padding: top/bottom 6 + in-row padding 6 = 12 (same as left/right 12). 6 more below the title.
  # popup row height is the larger of popup.height (minimum, 1 in rc) and the 'drawn' background height → the background is turned on, transparent
  local pad="icon.drawing=off label.drawing=off background.drawing=on background.color=0x00000000"
  a+=(--set "$p.p.a" $pad background.height=6 --set "$p.p.z" $pad background.height=6
      --set "$p.p.g" $pad background.height=6 drawing=$([ -n "$title" ] && echo on || echo off))
  a+=(--set "$p.p.t" drawing=$([ -n "$title" ] && echo on || echo off) icon="$title" icon.font="$FONT:Bold:11.0" icon.color=$TEXT2
      icon.padding_left=12 icon.padding_right=12 label.drawing=off
      background.drawing=on background.color=0x00000000 background.height=24)
  i=0
  while IFS=$'\t' read -r k v c click; do
    [ -z "$k$v" ] && continue
    case "$click" in                   # only link rows act. Clicking other rows does nothing (popup stays)
      "") cs="" ;;
      @*) cs="${click#@}" ;;           # starting with @ keeps the popup open after the click (calendar month paging)
      *) cs="$click; source '$POPUP_LIB'; popup_close_all" ;;
    esac
    local lp=0 id=on dr=on mc=${POPUP_MAXC:-0}   # _ : single-line text · = : calendar cell row (pulled in by one leading space, 7) · ~ : empty row (hidden)
    case "$k" in (_) lp=12; id=off; mc=0 ;; (=) lp=5; id=off; mc=0 ;; ("~") dr=off ;; esac
    a+=(--set "$p.p.$i" drawing=$dr icon.drawing=$id label.padding_left=$lp label.max_chars=$mc
        ${POPUP_W:+width=$POPUP_W} icon="$k" icon.width=${POPUP_KW:-64} icon.padding_left=12 icon.color=$TEXT3
        label="$v" label.color="${c:-$TEXT}" label.padding_right=12
        background.drawing=on background.color=0x00000000 background.height=24
        click_script="$cs")
    i=$((i + 1))
  done <<<"$data"

  a+=("${POPUP_XA[@]}")   # settings appended by the caller (--set …) — sent in the same command as the row contents so no intermediate state shows (the calendar ● row used to jump for one frame, 10-07)
  sketchybar "${a[@]}" >/dev/null 2>&1
  printf '%s\n%s' "$title" "$data" > "$POPUP_CACHE/popup.$p"
}

anim_label() {  # <item> <text> [more --set etc.] — change the text and animate the width over 0.2s (so the island width does not jump)
  local it="$1" t="$2" w; shift 2
  w=$(perl "${POPUP_LIB%/*}/width.pl" "$t")   # text width only — gaps between cells go in item padding (kept out of label.width)
  [ -n "$SB_BOOT" ] && { sketchybar --set "$it" label="$t" "$@" label.width=$w; return; }   # at startup apply at once (the bar is still off screen)
  sketchybar --set "$it" label="$t" "$@" --animate tanh 12 --set "$it" label.width=$w
}
