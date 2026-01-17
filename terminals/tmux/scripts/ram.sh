#!/bin/bash

# Get total physical memory in bytes
total_mem=$(sysctl -n hw.memsize)

# Get page size
page_size=$(vm_stat | grep "page size" | awk '{print $8}')

# Get memory stats
pages_active=$(vm_stat | awk '/Pages active/ {gsub(/\./, "", $3); print $3}')
pages_wired=$(vm_stat | awk '/Pages wired/ {gsub(/\./, "", $4); print $4}')

# Calculate used memory in bytes
used_mem=$(echo "($pages_active + $pages_wired) * $page_size" | bc)

# Calculate percentage
percentage=$(echo "scale=0; ($used_mem * 100) / $total_mem" | bc)

echo "  ${percentage}%"
