#!/bin/bash

# TODO: Open Reminders if closed or if reminders not open turn drawing off

REMINDERS_COUNT=$(osascript -l JavaScript -e "Application('Reminders').lists.byName('📥 Inbox').reminders.whose({completed: false}).name().length")

if [[ $REMINDERS_COUNT -gt 0 ]]; then
  sketchybar -m set reminders icon ""
  sketchybar -m set reminders label "$REMINDERS_COUNT"
else
  sketchybar -m set reminders icon ""
  sketchybar -m set reminders label ""
fi

