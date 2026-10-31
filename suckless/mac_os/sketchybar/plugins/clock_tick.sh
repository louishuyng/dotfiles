#!/bin/bash
# Clock text. SketchyBar calls this every second (not 'synced' to the system clock — it reads date and writes it in) → a minute change shows within 1 s
# The calendar popup is heavy, so it runs separately (the clock.cal item runs clock.sh every 10 s)
sketchybar --set clock icon="$(date +%m.%d)" label="$(date +%H:%M)"
