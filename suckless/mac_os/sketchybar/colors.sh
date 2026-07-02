#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh

# Source the colorscheme file
#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/colorscheme/list/retro-phosphor.sh
# ~/github/dotfiles-latest/colorscheme/list/retro-phosphor.sh

# These files have to be executable

# Lighter markdown headings
# 4 colors to the right for these ligher headings
# https://www.color-hex.com/color/987afb
#
# Given that color A (#987afb) becomes color B (#5b4996) when darkened 4 steps
# to the right, apply the same darkening ratio/pattern to calculate what color
# C (#37f499) becomes when darkened 4 steps to the right.
#
# Markdown heading 1 - color04
linkarzu_color18=#124726
# Markdown heading 2 - color02
linkarzu_color19=#5b2d00
# Markdown heading 3 - color03
linkarzu_color20=#18522d
# Markdown heading 4 - color01
linkarzu_color21=#6d3800
# Markdown heading 5 - color05
linkarzu_color22=#226739
# Markdown heading 6 - color08
# Also inactive tmux window, make it 6 darker to the right
linkarzu_color23=#2a1400
# Markdown heading foreground
# usually set to color10 which is the terminal background
linkarzu_color26=#000000

linkarzu_color04=#00e65c
linkarzu_color02=#ff9d00
linkarzu_color03=#66ff99
linkarzu_color01=#ffc94a
linkarzu_color05=#98ff98
linkarzu_color08=#ffe07a
linkarzu_color06=#caffca

# Colors to the right from https://www.colorhexa.com
# Terminal and neovim background
linkarzu_color10=#000000
# Lualine across, 1 color to the right of background
linkarzu_color17=#061006
# Markdown codeblock, 2 to the right of background
linkarzu_color07=#0b180b
# Background of inactive tmux pane, 3 to the right of background
linkarzu_color25=#102210
# line across cursor, 5 to the right of background
linkarzu_color13=#183818
# Tmux inactive windows, 7 colors to the right of background
linkarzu_color15=#245224

# Comments
linkarzu_color09=#4e6f4e
# Underline spellbad, color02 7 tones to the left in colorhexa
linkarzu_color11=#c96d00
# Underline spellcap, color04 7 tones to the left in colorhexa
linkarzu_color12=#d98a00
# Cursor and tmux windows text
linkarzu_color14=#d8ffd8
# Selected text
linkarzu_color16=#ffe680
# Cursor color, color04 9 tones to the left in colorhexa
linkarzu_color24=#00cc4f

# Wallpaper for this colorscheme
wallpaper="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Images/wallpapers/batman/batman-darker.png"

export MIC_LEVEL=72

### Sonokai
# export BLACK=0xff181819
# export WHITE=0xffe2e2e3
# export RED=0xfffc5d7c
# export GREEN=0xff9ed072
# export BLUE=0xff76cce0
# export YELLOW=0xffe7c664
# export ORANGE=0xfff39660
# export MAGENTA=0xffb39df3
# export GREY=0xff7f8490
# export TRANSPARENT=0x00000000
# export BG0=0xff2c2e34
# export BG1=0xff363944
# export BG2=0xff414550

#### Catppuccin
#export BLACK=0xff181926
#export WHITE=0xffcad3f5
#export RED=0xffed8796
#export GREEN=0xffa6da95
#export BLUE=0xff8aadf4
#export YELLOW=0xffeed49f
#export ORANGE=0xfff5a97f
#export MAGENTA=0xffc6a0f6
#export GREY=0xff939ab7
#export TRANSPARENT=0x00000000
#export BG0=0xff1e1e2e
#export BG0O50=0x801e1e2e
#export BG0O60=0x991e1e2e
#export BG0O70=0xB21e1e2e
#export BG0O80=0xCC1e1e2e
#export BG0O85=0xD91e1e2e
#export BG1=0x603c3e4f
#export BG2=0x60494d64

# # Eldritch Theme
# # https://github.com/eldritch-theme
# export BLACK=0xff181926
# export WHITE=0xffebfafa
# export RED=0xfff16c75
# export GREEN=0xff37f499
# export BLUE=0xff04d1f9
# export YELLOW=0xfff1fc79
# export ORANGE=0xfff7c67f
# export MAGENTA=0xffa48cf2
# export GREY=0xff323449
# export TRANSPARENT=0x00000000
# export BG0=0xff1e1e2e
# export BG0O50=0x801e1e2e
# export BG0O60=0x991e1e2e
# export BG0O70=0xB21e1e2e
# export BG0O80=0xCC1e1e2e
# # export BG0O85=0xD91e1e2e
# # export BG0O85=0xD9212337
# # This sets the color of the bar
# # Eldritch dark
# export BG0O85=0xCF0D1116
# # Eldritch light
# # export BG0O85=0xCF212337
# export BG1=0x603c3e4f
# export BG2=0x60494d64

# Linkarzu Theme
export BLACK=0xff${linkarzu_color10#\#}
export WHITE=0xff${linkarzu_color14#\#}
export RED=0xff${linkarzu_color11#\#}
export GREEN=0xff${linkarzu_color02#\#}
export BLUE=0xff${linkarzu_color03#\#}
export YELLOW=0xff${linkarzu_color12#\#}
export ORANGE=0xff${linkarzu_color04#\#}
export MAGENTA=0xff${linkarzu_color01#\#}
export GREY=0xff${linkarzu_color09#\#}
export TRANSPARENT=0x00000000
export BG0=0xff${linkarzu_color10#\#}
export BG005=0x0d${linkarzu_color10#\#}
export BG010=0x1a${linkarzu_color10#\#}
export BG015=0x26${linkarzu_color10#\#}
export BG020=0x33${linkarzu_color10#\#}
export BG025=0x40${linkarzu_color10#\#}
export BG030=0x4d${linkarzu_color10#\#}
export BG035=0x59${linkarzu_color10#\#}
export BG040=0x66${linkarzu_color10#\#}
export BG045=0x73${linkarzu_color10#\#}
export BG050=0x80${linkarzu_color10#\#}
export BG055=0x8c${linkarzu_color10#\#}
export BG060=0x99${linkarzu_color10#\#}
export BG065=0xa6${linkarzu_color10#\#}
export BG070=0xb3${linkarzu_color10#\#}
export BG075=0xbf${linkarzu_color10#\#}
export BG080=0xcc${linkarzu_color10#\#}
export BG085=0xd9${linkarzu_color10#\#}
export BG090=0xe6${linkarzu_color10#\#}
export BG095=0xf2${linkarzu_color10#\#}
export BG100=0xff${linkarzu_color10#\#}
# export BG0O85=0xD91e1e2e
# export BG0O85=0xD9212337
# This sets the color of the bar
# # Eldritch dark
# export BG085=0x55${linkarzu_color10#\#}
# Eldritch light
# export BG0O85=0xCF212337
export BG1=0x60${linkarzu_color13#\#}
export BG2=0x60${linkarzu_color07#\#}

# General bar colors
export BAR_COLOR=$BG080
export BAR_BORDER_COLOR=$BG2
export BACKGROUND_1=$BG1
export BACKGROUND_2=$BG2
export ICON_COLOR=$WHITE  # Color of all icons
export LABEL_COLOR=$WHITE # Color of all labels
export POPUP_BACKGROUND_COLOR=$BAR_COLOR
export POPUP_BORDER_COLOR=$WHITE
export SHADOW_COLOR=$BLACK

# Aerospace workspace indicator colors
export WORKSPACE_ACTIVE_COLOR=0xff${linkarzu_color04#\#}
export WORKSPACE_INACTIVE_COLOR=$GREY

# Spotify pill (and any other items that key off the focused-app palette)
export FRONT_APP_COLOR=$WHITE
export DIM=$GREY
