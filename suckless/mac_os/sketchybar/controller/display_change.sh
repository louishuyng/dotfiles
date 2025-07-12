#!/usr/bin/env fish

set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)
set IS_DARK_THEME (osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

if test $USE_EXTERNAL_DISPLAY -eq 1
    sketchybar --bar position=top height=28

    if test "$IS_DARK_THEME" = "false"
        sketchybar --bar color=0xffE4E4E4
    else
        sketchybar --bar color=0xff272727
    end
else
    sketchybar --bar position=top height=32

    if test "$IS_DARK_THEME" = "false"
        sketchybar --bar color=0xffE4E4E4
    else
        sketchybar --bar color=0xff000000
    end
end
