#!/opt/homebrew/bin/bash

total_mem=$(sysctl -n hw.memsize)
read page_size pages_active pages_wired < <(vm_stat | awk '
	/page size of/ { ps = $8 }
	/Pages active/ { gsub(/\./, "", $3); pa = $3 }
	/Pages wired/  { gsub(/\./, "", $4); pw = $4 }
	END { print ps, pa, pw }
')
used_mem=$(( (pages_active + pages_wired) * page_size ))
RAM=$(( used_mem * 100 / total_mem ))

sketchybar --set "$NAME" label=" ${RAM}%"
