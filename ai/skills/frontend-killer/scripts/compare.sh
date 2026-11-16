#! /bin/bash
# Compare a Figma export with an implementation screenshot, band by band.
# Prints the mismatch per horizontal band and writes a Figma | implementation | diff
# strip for every band over the threshold, so the reviewer knows where to look.
set -e

info() { printf '%s\n' "$1"; }
fail() {
  printf 'compare: %s\n' "$1" >&2
  exit 2
}

usage() {
  cat <<'EOF'
usage: compare.sh <figma.png> <impl.png> <out-dir> [options]
  --bands N       horizontal bands to score (default 12)
  --threshold P   percent of differing pixels that fails a band (default 0.5)
  --fuzz P        colour tolerance in percent, absorbs anti-aliasing (default 6)
  --crop-top PX   rows to drop from the top of both images, e.g. the status bar (default 0)
exit: 0 every band under the threshold, 1 at least one band over, 2 unusable input
EOF
  exit 2
}

[ $# -ge 3 ] || usage
figma="$1"
impl="$2"
out="$3"
shift 3

bands=12
threshold=0.5
fuzz=6
crop_top=0
while [ $# -gt 0 ]; do
  case "$1" in
    --bands) bands="$2" ;;
    --threshold) threshold="$2" ;;
    --fuzz) fuzz="$2" ;;
    --crop-top) crop_top="$2" ;;
    *) usage ;;
  esac
  shift 2
done

command -v magick >/dev/null || fail "ImageMagick 7 is required (brew install imagemagick)"
[ -f "$figma" ] || fail "missing file: $figma"
[ -f "$impl" ] || fail "missing file: $impl"

read -r fw fh <<<"$(magick identify -format '%w %h' "$figma[0]")"
read -r iw ih <<<"$(magick identify -format '%w %h' "$impl[0]")"

# Scaling one side to fit the other blurs every edge and hides real size differences.
[ "$fw" -eq "$iw" ] || fail "widths differ (figma ${fw}px, impl ${iw}px). Re-export or re-capture at the same width and scale; do not resize."

height=$((fh < ih ? fh : ih))
if [ "$fh" -ne "$ih" ]; then
  info "WARN heights differ (figma ${fh}px, impl ${ih}px): comparing the top ${height}px only. The rest is unchecked."
fi
height=$((height - crop_top))
[ "$height" -ge "$bands" ] || fail "image too short for $bands bands"

mkdir -p "$out"
crop="${fw}x${height}+0+${crop_top}"
magick "$figma[0]" -crop "$crop" +repage "$out/_figma.png"
magick "$impl[0]" -crop "$crop" +repage "$out/_impl.png"
magick compare -fuzz "${fuzz}%" "$out/_figma.png" "$out/_impl.png" "$out/diff.png" 2>/dev/null || true

band_height=$((height / bands))
failed=0
info "band  rows(px)        mismatch  status"
for ((i = 0; i < bands; i++)); do
  y=$((i * band_height))
  h=$band_height
  [ "$i" -eq $((bands - 1)) ] && h=$((height - y))
  geometry="${fw}x${h}+0+${y}"
  # compare exits 1 when the images differ, which is an expected result here.
  differing=$(magick compare -metric AE -fuzz "${fuzz}%" \
    "$out/_figma.png[$geometry]" "$out/_impl.png[$geometry]" null: 2>&1 || true)
  differing=${differing%% *}
  percent=$(awk -v d="$differing" -v t="$((fw * h))" 'BEGIN { printf "%.2f", (d + 0) * 100 / t }')
  status=ok
  if awk -v p="$percent" -v t="$threshold" 'BEGIN { exit !(p > t) }'; then
    status=LOOK
    failed=$((failed + 1))
    strip=$(printf '%s/band-%02d.png' "$out" "$((i + 1))")
    magick "$out/_figma.png[$geometry]" "$out/_impl.png[$geometry]" "$out/diff.png[$geometry]" \
      -background '#ff00ff' -splice 6x0 +append -chop 6x0 "$strip"
  fi
  printf '%-5s %-15s %7s%%  %s\n' "$((i + 1))" "$((y + crop_top))-$((y + crop_top + h))" "$percent" "$status"
done

info "strips: figma | implementation | diff, in $out/band-NN.png"
if [ "$failed" -gt 0 ]; then
  info "RESULT $failed of $bands bands over ${threshold}%: open each band-NN.png and explain every difference."
  exit 1
fi
info "RESULT all $bands bands under ${threshold}%"
