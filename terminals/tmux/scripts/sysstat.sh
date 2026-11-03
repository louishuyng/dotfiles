#!/opt/homebrew/bin/bash
# cpu · mem · disk for the status bar, read from the cache sketchybar's
# meters.sh writes every 5s, so tmux never forks top/vm_stat/diskutil itself.
# Prints nothing when sketchybar is not running (cache older than 30s).
CACHE="$HOME/.cache/sketchybar"

fresh() { [ -f "$1" ] && (($(date +%s) - $(stat -f %m "$1") < 30)); }

fresh "$CACHE/cat" || exit 0
read -r cpu mem <"$CACHE/cat"

# disk is cached for 60s by meters.sh, so it only needs to exist
disk=$(awk '{print $(NF-2)}' "$CACHE/disk" 2>/dev/null) # "324 / 494 GB · 170 GB free" → 170

# icons as escapes: literal private-use glyphs get dropped by some editors (see agents.sh)
ICON_CPU=$'\U0000F4BC'  # oct-cpu
ICON_MEM=$'\U000F035B'  # md-memory
ICON_DISK=$'\U000F02CA' # md-harddisk

color() { (($1 >= 80)) && echo '#e78284' || echo "$2"; }

SEP=' #[fg=#51576d]│ '
printf '#[fg=%s]%s %s%%%s#[fg=%s]%s %s%%' "$(color "$cpu" '#a6d189')" "$ICON_CPU" "$cpu" "$SEP" "$(color "$mem" '#8caaee')" "$ICON_MEM" "$mem"
[ -n "$disk" ] && printf '%s#[fg=#838ba7]%s %sG' "$SEP" "$ICON_DISK" "$disk"
printf '%s#[default]' "$SEP"
