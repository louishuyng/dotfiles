#!/usr/bin/env fish

# Get dark mode status
set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)
set IS_DARK_THEME (osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

set LIST_SPACES_INDEX I D T W C O A

if test "$IS_DARK_THEME" = "false"
  sketchybar --bar color=0xffE7E9EF
  sketchybar --set '/.*/' label.color=0xff999999

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i icon.color=0xff999999
    sketchybar --set space.$i icon.highlight_color=0xff6F42C1
  end

  sketchybar --set separator_space icon.color=0xff005cc5

  sketchybar --set cpu label.color=0xff198E31 icon.color=0xff198E31
  sketchybar --set ram label.color=0xffBC8705 icon.color=0xffBC8705
  sketchybar --set battery label.color=0xff6F42C1 icon.color=0xff6F42C1
  sketchybar --set front_app icon.color=0xff1D1F21 label.color=0xff1D1F21
  sketchybar --set keyboard icon.color=0xff000000
  # sketchybar --set airpods icon.color=0xff000000
else
  if test $USE_EXTERNAL_DISPLAY -eq 1
    sketchybar --bar color=0xff272727
  else
    sketchybar --bar color=0xff000000
  end

  sketchybar --set '/.*/' label.color=0xff7F7F7F

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i icon.color=0xff7F7F7F
    sketchybar --set space.$i icon.highlight_color=0xffA6DA95
  end

  sketchybar --set separator_space icon.color=0xffBABBF1

  sketchybar --set cpu label.color=0xffA6DA95
  sketchybar --set ram label.color=0xffFCA61B
  sketchybar --set battery label.color=0xffBFAFFE icon.color=0xffBFAFFE

  sketchybar --set front_app icon.color=0xffC2C2C2 label.color=0xffC2C2C2
  sketchybar --set keyboard icon.color=0xFFD3D3D4
  # sketchybar --set airpods icon.color=0xFFD3D3D4
end

tmux source ~/.tmux.conf
