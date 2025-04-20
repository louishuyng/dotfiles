#!/usr/bin/env fish

# Get dark mode status
set USE_EXTERNAL_DISPLAY (system_profiler SPDisplaysDataType | grep BenQ | wc -l)
set IS_DARK_THEME (osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

set LIST_SPACES_INDEX I C T B W R M A

if test "$IS_DARK_THEME" = "false"
  sketchybar --bar color=0xffE4E2CE
  sketchybar --set '/.*/' label.color=0xff999999

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i icon.color=0xff999999
    sketchybar --set space.$i icon.highlight_color=0xff6C71C4
  end

  sketchybar --set cpu label.color=0xff198E31 icon.color=0xff198E31
  sketchybar --set ram label.color=0xffBC8705 icon.color=0xffBC8705
  sketchybar --set battery label.color=0xffC94A3A icon.color=0xffD54598
  sketchybar --set front_app label.color=0xffEAEAEA icon.color=0xffEAEAEA background.color=0xff1D1F21
else
  if test $USE_EXTERNAL_DISPLAY -eq 1
    sketchybar --bar color=0xff272727
  else
    sketchybar --bar color=0xff000000
  end

  sketchybar --set '/.*/' label.color=0xff7F7F7F

  for i in $LIST_SPACES_INDEX
    sketchybar --set space.$i icon.color=0xff868686
    sketchybar --set space.$i icon.highlight_color=0xffAF87D7
  end

  sketchybar --set cpu label.color=0xffA6DA95 icon.color=0xffA6DA95
  sketchybar --set ram label.color=0xffEED49F icon.color=0xffEED49F
  sketchybar --set battery label.color=0xffED8796 icon.color=0xffED8796
  sketchybar --set front_app label.color=0xff122323 icon.color=0xff122323 background.color=0xff07B89C
end

tmux source ~/.tmux.conf
