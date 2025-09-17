#!/usr/bin/env fish

set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)
set IS_DARK_THEME (osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

# if test $USE_EXTERNAL_DISPLAY -eq 1
#      sketchybar --bar height=29
# else
#      sketchybar --bar height=29
# end
