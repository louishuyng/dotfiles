#!/bin/bash

# Check if plugged in or on battery
power_source=$(pmset -g ps | head -1)

if [[ $power_source == *"AC Power"* ]]; then
    # Plugged in - show charging icon
    echo "󱐋 AC"
else
    # On battery - try to get power draw
    # Get battery percentage and time remaining
    battery_info=$(pmset -g batt | grep -Eo "\d+%")

    # Estimate power draw based on discharge rate
    # This is an approximation since exact wattage requires sudo powermetrics
    time_remaining=$(pmset -g batt | grep -o "[0-9]*:[0-9]*" | head -1)

    if [ -n "$time_remaining" ]; then
        # Convert time to minutes for rough calculation
        hours=$(echo "$time_remaining" | cut -d: -f1)
        minutes=$(echo "$time_remaining" | cut -d: -f2)
        total_minutes=$((hours * 60 + minutes))

        # Rough estimation: MacBook battery is ~50-100Wh
        # If draining in X hours, approximate wattage
        if [ $total_minutes -gt 0 ]; then
            # Assume 70Wh battery (rough average for MacBooks)
            battery_pct=$(echo "$battery_info" | sed 's/%//')
            remaining_wh=$(echo "scale=0; 70 * $battery_pct / 100" | bc)
            watt=$(echo "scale=0; ($remaining_wh * 60) / $total_minutes" | bc)
            echo "󱐋 ${watt}W"
        else
            echo "󱐋 ${battery_info}"
        fi
    else
        echo "󱐋 ${battery_info}"
    fi
fi
