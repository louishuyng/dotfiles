#!/usr/bin/env fish

set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)

if test $USE_EXTERNAL_DISPLAY -eq 1
    sketchybar --bar position=bottom color=0xff272727
else
    sketchybar --bar position=top color=0xff000000
end
