#!/bin/bash
# Album art self-check — catches the known problem (big art going blurry again). Exits 0 when fine, 1 + reason otherwise
#   bash ~/.config/sketchybar/plugins/check_art.sh
MC=$(command -v media-control || echo /opt/homebrew/bin/media-control)
J=$("$MC" get 2>/dev/null); g() { plutil -extract "$1" raw -o - - <<<"$J" 2>/dev/null; }
B=$(g bundleIdentifier); T=$(g title); A=$(g artist)
{ IFS=$'\t' read -r SK SQ SN; } < "$HOME/.cache/sketchybar/art.state" 2>/dev/null
P=$(cat "$HOME/.cache/sketchybar/art.path" 2>/dev/null)
echo "source: ${B:-none} · track: ${T:-—} / ${A:-—}"
echo "art state: ${SQ:-none} (retry ${SN:-0}) · file: ${P:-none} $( [ -s "$P" ] && sips -g pixelWidth "$P" | awk '/pixelWidth/{print $2"px"}')"
[ -z "$B" ] && { echo "OK — nothing playing"; exit 0; }
[ "$SK" = "$T|$A" ] || { echo "problem: art is not for the current track (state track: $SK)"; exit 1; }
[ -s "$P" ] || { echo "problem: art file missing"; exit 1; }
case "$B" in com.google.Chrome|com.brave.Browser|com.citrolabs.ego.lite)
  [ "$SQ" = big ] && { echo "OK — browser tab, big art"; exit 0; }
  PIDB=$(g processIdentifier)
  R=$("$HOME/.config/sketchybar/helper/chromejs" "$PIDB" music.youtube.com '(navigator.mediaSession.metadata||{}).title||""' 2>&1); rc=$?
  [ $rc = 2 ] && { echo "problem: cannot connect to the playing process ($PIDB)"; exit 1; }
  [ $rc = 1 ] && { echo "problem: JavaScript does not run in the tab — in that Chrome (profile) check View > Developer > 'Allow JavaScript from Apple Events'"; exit 1; }
  [ -z "$R" ] && { echo "problem: no music.youtube.com tab found in the playing Chrome ($PIDB) (an app window, or another site)"; exit 1; }
  [ "$R" = "$T" ] || { echo "problem: the tab track ($R) differs from the current track — right after a track change, try again shortly"; exit 1; }
  echo "problem: big art not there yet (retry #${SN:-0}, continues every 20 s)"; exit 1 ;;
  *) echo "OK — app (${B}): for this source media-control art (120px) is the best available"; exit 0 ;;
esac
