#! /bin/bash
# Print the WCAG contrast ratio between two colours and which thresholds it meets.
set -e

fail() {
  printf 'contrast: %s\n' "$1" >&2
  exit 2
}

[ $# -eq 2 ] || fail "usage: contrast.sh <foreground-hex> <background-hex>   e.g. contrast.sh '#6b7280' '#ffffff'"

normalise() {
  local hex="${1#\#}"
  if [ ${#hex} -eq 3 ]; then
    hex="${hex:0:1}${hex:0:1}${hex:1:1}${hex:1:1}${hex:2:1}${hex:2:1}"
  fi
  # An alpha channel is dropped: blend a translucent colour over its background first.
  [ ${#hex} -eq 8 ] && hex="${hex:0:6}"
  [[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || fail "not a hex colour: $1"
  printf '%d %d %d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

foreground=$(normalise "$1")
background=$(normalise "$2")
read -r fr fg fb <<<"$foreground"
read -r br bg bb <<<"$background"

awk -v fr="$fr" -v fg="$fg" -v fb="$fb" -v br="$br" -v bg="$bg" -v bb="$bb" '
function channel(v) { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4 }
function luminance(r, g, b) { return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b) }
BEGIN {
  a = luminance(fr, fg, fb); b = luminance(br, bg, bb)
  if (a < b) { t = a; a = b; b = t }
  ratio = (a + 0.05) / (b + 0.05)
  printf "ratio %.2f:1\n", ratio
  printf "normal text (4.5:1)          %s\n", (ratio >= 4.5 ? "pass" : "FAIL")
  printf "large text, UI, icons (3:1)  %s\n", (ratio >= 3 ? "pass" : "FAIL")
  exit (ratio >= 4.5 ? 0 : 1)
}'
