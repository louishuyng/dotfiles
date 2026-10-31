#!/bin/bash
# tailscale cell: just a 3×3 pixel-dot icon — on (middle row + bottom middle --text) / off (all 9 --text-3). Every 30 s + when the popup opens
# popup TAILSCALE (width 336): status · devices (this device → online → offline, by name. This device is bold; Macs with screen sharing get ↗ after the name — click opens vnc) · settings
#   two colors on one row (name --text · IP on the right --text-2): the right-hand text is laid on as an image (helper/textpng) — same method as 'failed' in the volume popup
# Tailscale settings (on/off, serve) are not touched
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
P="$CONFIG_DIR/plugins"; C="$HOME/.cache/sketchybar"; PX="$C/px"
TS=""; for t in "$(command -v tailscale)" /usr/local/bin/tailscale /opt/homebrew/bin/tailscale /Applications/Tailscale.app/Contents/MacOS/Tailscale; do   # /usr/local/bin may be missing from the SketchyBar PATH
  [ -n "$t" ] && [ -x "$t" ] && { TS=$t; break; }; done
[ -n "$TS" ] || { sketchybar --set ts drawing=off; exit 0; }
J=$(perl -e 'alarm 5; exec @ARGV' "$TS" status --json 2>/dev/null)
IFS=$'\t' read -r STATE NET <<<"$(python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
print(d.get("BackendState","") + "\t" + ((d.get("CurrentTailnet") or {}).get("Name") or ""))' <<<"$J")"
ON=0; [ "$STATE" = Running ] && ON=1
sketchybar --set ts drawing=on icon.background.image="$PX/ts_$([ $ON = 1 ] && echo on || echo off).png"

W=336; SAY="$TS"
img() { # <text> <color> → image path (cached)
  local f="$C/ti/$(printf '%s|%s' "$1" "$2" | md5 | cut -c1-12).png"; mkdir -p "$C/ti"
  [ -f "$f" ] || "$CONFIG_DIR/helper/textpng" "$1" "$2" 12 "$f"; echo "$f"; }
R=()   # right-hand image per row number
{ if [ $ON = 1 ]; then printf 'status\tconnected\t%s\t\n' "$TEXT"; else printf 'status\toff\t%s\t\n' "$TEXT3"; fi
  k=1
  if [ $ON = 1 ]; then
    python3 -c 'import json,sys
d=json.load(sys.stdin); rows=[]
def full(p): return (p.get("DNSName") or "").split(".")[0] or p.get("HostName","?")
import os.path
allp=[d.get("Self") or {}]+list((d.get("Peer") or {}).values())
pre=os.path.commonprefix([full(p) for p in allp]); pre=pre[:pre.rfind("-")+1] if len(allp)>1 and "-" in pre else ""   # drop the common prefix (e.g. myname-) — like the design: macbookpro·iphone
def name(p): return full(p)[len(pre):] or full(p)
s=d.get("Self") or {}
rows.append((0,name(s),(s.get("TailscaleIPs") or [""])[0],1,1,""))
peers=sorted((d.get("Peer") or {}).values(), key=lambda p:(not p.get("Online"), name(p)))
for p in peers: rows.append((1,name(p),(p.get("TailscaleIPs") or [""])[0],1 if p.get("Online") else 0,0,(p.get("DNSName") or "").rstrip(".") if p.get("OS")=="macOS" else ""))
for _,n,ip,on,me,vnc in rows[:8]:
  if len(n) > 16: n = n[:15] + "…"   # keep clear of the IP on the right (max 15 chars): 312 − 64 − IP 108 − padding → name cell about 16 chars (+ this device)
  print("%s\t%s\t%s\t%d\t%s" % (n, ip, "me" if me else "peer", on, vnc))' <<<"$J" |
    while IFS=$'\t' read -r n ip who on vnc; do
      # Mac devices (online): clicking the row opens screen sharing (vnc://<MagicDNS name>, no address used); other online devices copy the IP. This device has no click
      if [ "$on" = 1 ]; then cl=""; [ "$who" = peer ] && cl="printf %s '$ip' | pbcopy"; [ -n "$vnc" ] && cl="open 'vnc://$vnc'"
        printf '●\t%s\t%s\t%s\n' "$n" "$TEXT" "$cl"
      else printf '○\t%s\t%s\t\n' "$n" "$TEXT3"; fi
    done
  fi
} > "$C/ts.rows"
DEV=$(python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
def name(p): return (p.get("DNSName") or "").split(".")[0] or p.get("HostName","?")
if d.get("BackendState")=="Running":
  s=d.get("Self") or {}; print((s.get("TailscaleIPs") or [""])[0] + "\t1")
  for p in sorted((d.get("Peer") or {}).values(), key=lambda p:(not p.get("Online"), name(p)))[:7]:
    print(((p.get("TailscaleIPs") or [""])[0] if p.get("Online") else "offline") + "\t" + ("1" if p.get("Online") else "0"))' <<<"$J")
N=$(grep -c . "$C/ts.rows")
{ cat "$C/ts.rows"
  for ((i = N; i < 9; i++)); do printf '~\t.\t\t\n'; done
  printf 'open\tadmin ↗\t%s\topen "https://login.tailscale.com/admin"\n' "$TEXT2"
} | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_W=$W popup_rows ts TAILSCALE
# right column (images): status row = tailnet name --text-3, device rows = IP --text-2 / offline --text-3. Right end = padding 12
right() { # <row item> <text> <color>
  local f w; f=$(img "$2" "$3"); w=$(( $(sips -g pixelWidth "$f" 2>/dev/null | awk '/pixelWidth/{print $2}') / 2 ))
  a+=(--set "$1" background.image="$f" background.image.scale=0.5 background.image.drawing=on background.image.padding_left=$(( W - 10 - w )) background.image.y_offset=-1); }   # right margin of the image 2 · drawn 1pt high inside a popup, so −1 (measured)
a=()
# the popup draws left-cell text and dots 1pt above the value text → lowered 1pt (same correction as measured on the volume popup). The ● dot is --accent (online)
for i in 0 1 2 3 4 5 6 7 8 9; do a+=(--set ts.p.$i icon.y_offset=-1 background.image.drawing=off); done
# this device (always the first device row = ts.p.1) gets a bold name — the same Bold as the popup title, other devices Regular (by request 10-02: a typeface change instead of a 'this device' caption)
for i in 2 3 4 5 6 7 8; do a+=(--set ts.p.$i label.font="$FONT:Regular:12.0" icon.background.image.drawing=off); done
[ $ON = 1 ] && a+=(--set ts.p.1 label.font="$FONT:Bold:12.0") || a+=(--set ts.p.1 label.font="$FONT:Regular:12.0")
[ $ON = 1 ] && [ -n "$NET" ] && right ts.p.0 "$NET" "$TEXT3"
# Macs with screen sharing (online) get ↗ right after the name — same --text-2 as other popup links (admin ↗ etc.) · one space apart. Two colors on one row, so only the ↗ is a text image
#   position = value cell 64 + name width + space 7.2 − margin inside the image 1
AR=$(img "↗" "$TEXT2")
VN=$(python3 -c 'import json,sys
d=json.load(sys.stdin)
def full(p): return (p.get("DNSName") or "").split(".")[0] or p.get("HostName","?")
import os.path
allp=[d.get("Self") or {}]+list((d.get("Peer") or {}).values())
pre=os.path.commonprefix([full(p) for p in allp]); pre=pre[:pre.rfind("-")+1] if len(allp)>1 and "-" in pre else ""
peers=sorted((d.get("Peer") or {}).values(), key=lambda p:(not p.get("Online"), full(p)[len(pre):] or full(p)))
for i,p in enumerate(peers[:7]):
  if p.get("Online") and p.get("OS")=="macOS": print(i+2, (full(p)[len(pre):] or full(p))[:16])' <<<"$J" 2>/dev/null)
while read -r row nm; do [ -z "$row" ] && continue
  # the row background image is used by the IP on the right, so ↗ goes in as the icon (●) background image — position is relative to the left end of the row (measured); name end ↔ ↗ 8.5 = same as admin ↗
  a+=(--set ts.p.$row icon.background.drawing=on icon.background.color=0x00000000 icon.background.image="$AR" icon.background.image.scale=0.5 \
      icon.background.image.drawing=on icon.background.image.y_offset=-1 icon.background.image.padding_left=$(( 64 + $(perl "$P/width.pl" "$nm") + 7 )))
done <<<"$VN"
i=1; while IFS=$'\t' read -r ip on; do [ -z "$ip" ] && continue
  if [ "$on" = 1 ]; then a+=(--set ts.p.$i icon.color=$ACCENT); right ts.p.$i "$ip" "$TEXT2"; else right ts.p.$i offline "$TEXT3"; fi
  i=$((i + 1)); done <<<"$DEV"
sketchybar "${a[@]}" 2>/dev/null
