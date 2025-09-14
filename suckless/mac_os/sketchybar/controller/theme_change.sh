#!/usr/bin/env fish

# Get dark mode status
set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)
set IS_DARK_THEME (osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

set LIST_SPACES_INDEX I D T W R P C A

if test "$IS_DARK_THEME" = "false"
  sketchybar --bar color=0xffE4E4E4
  sketchybar --set '/.*/' label.color=0xff999999

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i label.color=0xff999999
    sketchybar --set space.$i label.highlight_color=0xff198E30
  end

  sketchybar --set separator_space icon.color=0xff005cc5

  sketchybar --set cpu label.color=0xff198E31
  sketchybar --set ram label.color=0xffBC8705
  sketchybar --set disk label.color=0xffbf3989
  sketchybar --set battery label.color=0xff6F42C1 icon.color=0xff6F42C1
  sketchybar --set focus icon.color=0xffE4E4E4 label.color=0xffE4E4E4
  sketchybar --set front_app background.color=0xff6F42C1 icon.color=0xffffffff label.color=0xffffffff
  sketchybar --set keyboard icon.color=0xff000000 label.color=0xff000000
  sketchybar --set airpods icon.color=0xff151BB5 label.color=0xff151BB5
  sketchybar --set ai label.color=0xFF000000
else
  sketchybar --bar color=0xff272727

  sketchybar --set '/.*/' label.color=0xff7F7F7F

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i label.color=0xff7F7F7F
    sketchybar --set space.$i label.highlight_color=0xff4FFA7B
  end

  sketchybar --set separator_space icon.color=0xffBABBF1

  sketchybar --set cpu label.color=0xffA6DA95
  sketchybar --set ram label.color=0xffFCA61B
  sketchybar --set disk label.color=0xffE78284
  sketchybar --set battery label.color=0xffBFAFFE icon.color=0xffBFAFFE

  sketchybar --set focus background.color=0xffF1FA8C label.color=0xff000000 icon.color=0xff000000
  sketchybar --set front_app icon.color=0xffCBA6F7 label.color=0xffCBA6F7
  sketchybar --set keyboard icon.color=0xFFD3D3D4 label.color=0xFFD3D3D4
  sketchybar --set airpods icon.color=0xFFB7BD73 label.color=0xFFB7BD73
  sketchybar --set ai label.color=0xFF000000
end

tmux source ~/.tmux.conf
