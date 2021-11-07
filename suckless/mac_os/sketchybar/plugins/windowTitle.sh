#!/bin/bash

WINDOW_INFO=$(osascript -e '
  global frontApp, frontAppName, windowTitle
  tell application "System Events"
    set frontApp to first application process whose frontmost is true
    set frontAppName to name of frontApp
    tell process frontAppName
      tell (1st window whose value of attribute "AXMain" is true)
        set windowTitle to value of attribute "AXTitle"
      end tell
    end tell
  end tell

  if (count of windowTitle) is greater than 50 then
    set windowTitle to do shell script "echo " & windowTitle & "| cut -c 1-50"
    set windowTitle to windowTitle & "…"
  end if

  if windowTitle is not "" then
    return windowTitle
  else
    return frontAppName
  end if
')

sketchybar -m set window_title label "$WINDOW_INFO"
