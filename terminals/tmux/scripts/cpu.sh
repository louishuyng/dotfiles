#!/bin/bash

# Get CPU usage
cpu_usage=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d'%' -f1)

# Round to integer
cpu_usage=$(printf "%.0f" "$cpu_usage")

echo "󰍛 ${cpu_usage}%"
