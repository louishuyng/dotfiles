#!/bin/bash
# Now-playing info on one line: state<TAB>app<TAB>title<TAB>artist<TAB>elapsed s<TAB>length s<TAB>source
#   state = playing | paused | none. source = mc (media-control, every app including browsers) | music (Apple Music, nothing to install)
# Since macOS 15.4 ordinary programs cannot read Now Playing → use media-control (brew) when it is installed
F="$HOME/.cache/sketchybar/media_fake"; [ -f "$F" ] && { cat "$F"; exit 0; }   # fake input for testing
MC=$(command -v media-control || echo /opt/homebrew/bin/media-control)   # it is on SketchyBar's PATH too, but to be sure
if [ -x "$MC" ]; then
  J=$("$MC" get 2>/dev/null)
  if [ -n "$J" ] && [ "$J" != null ]; then
    g() { plutil -extract "$1" raw -o - - <<<"$J" 2>/dev/null; }
    B=$(g bundleIdentifier); P=$(g playing); C="$HOME/.cache/sketchybar/appname.$B"
    case "$B" in
      com.apple.Music) echo 'Apple Music' > "$C" ;;
      *) [ -f "$C" ] || { a=$(mdfind "kMDItemCFBundleIdentifier == '$B'" | head -1); a=${a##*/}; a=${a%.app}; echo "${a:-$B}" | tr '[:upper:]' '[:lower:]' > "$C"; } ;;
    esac
    [ "$P" = true ] && S=playing || S=paused
    EL=$(g elapsedTime | cut -d. -f1)
    if [ "$S" = playing ]; then   # elapsedTime is the value at timestamp — while playing, add the time passed since
      TS=$(g timestamp); ts=$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$TS" +%s 2>/dev/null); [ -n "$ts" ] && EL=$(( ${EL:-0} + $(date +%s) - ts ))
    fi
    # album art. State file art.state = "track<TAB>big|small<TAB>retry count"
    #   · a different file name per track and per download (art-<hash>-<time>.jpg) — overwriting the same name makes SketchyBar keep showing the old picture
    #   · if the big art (YouTube Music original 544px from the browser tab) is not available, show the 120px one first and retry until the big one arrives (every refresh for the first 10 tries, then every 20 s)
    #   · never overwrite a track's big art with the small one — 'once sharp, never blurry again' (by request, 10-02)
    #   · the page may still hold the previous track's info (right after a track change), so the big art counts only when the page title equals the current track title
    K="$(g title)|$(g artist)"; AP="$HOME/.cache/sketchybar/art.path"; AS_="$HOME/.cache/sketchybar/art.state"
    { IFS=$'\t' read -r SK SQ SN; } < "$AS_" 2>/dev/null
    BROWSER=0; case "$B" in com.google.Chrome|com.brave.Browser|com.citrolabs.ego.lite) BROWSER=1 ;; esac
    # retry: every refresh for the first 10 tries, then every 20 s indefinitely (so reopening the tab later still switches to that track's big art). Time of last try = art.try
    NEED=0; [ "$K" != "$SK" ] && NEED=1
    if [ "$K" = "$SK" ] && [ "$SQ" != big ] && [ $BROWSER = 1 ]; then
      if [ "${SN:-0}" -lt 10 ] || [ $(( $(date +%s) - $(cat "$HOME/.cache/sketchybar/art.try" 2>/dev/null || echo 0) )) -ge 20 ]; then NEED=1; fi
    fi
    [ $NEED = 1 ] && date +%s > "$HOME/.cache/sketchybar/art.try"
    if [ $NEED = 1 ]; then
      A="$HOME/.cache/sketchybar/art-$(printf '%s' "$K" | md5 | cut -c1-12)-$(date +%s).jpg"
      BIG=0
      if [ $BROWSER = 1 ]; then   # needs 'View > Developer > Allow JavaScript from Apple Events' turned on in that browser (the profile of that tab)
        # talk directly to the very process that is playing (media-control processIdentifier) — with two Chrome instances AppleScript sees only one and could not find the tab (confirmed 10-02)
        PIDB=$(g processIdentifier)
        R=$(perl -e 'alarm 3; exec @ARGV' "${CONFIG_DIR:-$HOME/.config/sketchybar}/helper/chromejs" "$PIDB" music.youtube.com \
          '(()=>{const md=navigator.mediaSession.metadata||{};let b="",m=0;for(const x of (md.artwork||[])){const s=parseInt(String(x.sizes).split("x")[0])||0;if(s>=m){m=s;b=x.src}}return (md.title||"")+"\t"+b})()' 2>/dev/null)
        RT=${R%%$'\t'*}; U=${R#*$'\t'}
        if [ "$RT" = "$(g title)" ]; then case "$U" in https://*) curl -sfL --max-time 5 -o "$A" "$U" 2>/dev/null && [ -s "$A" ] && BIG=1 ;; esac; fi
      fi
      if [ $BIG = 1 ] || [ "$K" != "$SK" ]; then
        [ $BIG = 1 ] || { g artworkData | base64 -d > "$A" 2>/dev/null || true; }   # new track but no big art yet: 120px for now
        if [ -s "$A" ]; then   # make it square: square stays as is, otherwise fit the whole picture and fill the rest with a blurred copy of it (helper/artfit, 476px = 238pt@2x)
          "${CONFIG_DIR:-$HOME/.config/sketchybar}/helper/artfit" "$A" "$A.tmp" 476 2>/dev/null && mv "$A.tmp" "$A"
          for f in "$HOME"/.cache/sketchybar/art-*.jpg; do [ "$f" = "$A" ] || rm -f "$f"; done   # delete old art
          printf '%s' "$A" > "$AP"
          if [ $BIG = 1 ]; then printf '%s\tbig\t0' "$K" > "$AS_"; else printf '%s\tsmall\t1' "$K" > "$AS_"; fi
        else rm -f "$A" "$AP"; printf '%s\tnone\t1' "$K" > "$AS_"; fi   # no art — the popup shows the ALBUM ART cell
      else
        rm -f "$A"; printf '%s\t%s\t%s' "$K" "$SQ" "$(( ${SN:-0} + 1 ))" > "$AS_"   # same track, big art not there yet — keep the current picture and try again next time
      fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\tmc\n' "$S" "$(cat "$C")" "$(g title)" "$(g artist)" "$EL" "$(g duration | cut -d. -f1)"
    exit 0
  fi
fi
if [ "$(osascript -e 'application "Music" is running' 2>/dev/null)" = true ]; then
  osascript <<'AS' 2>/dev/null && exit 0
tell application "Music"
  if player state is stopped then error "none"
  set s to "paused"
  if player state is playing then set s to "playing"
  return s & tab & "Apple Music" & tab & (name of current track) & tab & (artist of current track) & tab & ((player position as integer) as text) & tab & ((duration of current track as integer) as text) & tab & "music"
end tell
AS
fi
printf 'none\t\t\t\t\t\t\n'
