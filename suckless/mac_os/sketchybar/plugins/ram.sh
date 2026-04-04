#!/opt/homebrew/bin/bash

total_mem=$(sysctl -n hw.memsize)
page_size=$(vm_stat | awk '/page size/{print $8}')
pages_active=$(vm_stat | awk '/Pages active/{gsub(/\./, "", $3); print $3}')
pages_wired=$(vm_stat | awk '/Pages wired/{gsub(/\./, "", $4); print $4}')
used_mem=$(( (pages_active + pages_wired) * page_size ))
RAM=$(echo "scale=0; ($used_mem * 100) / $total_mem" | bc)

sketchybar --set "$NAME" label="R:${RAM}%"
