#!/opt/homebrew/bin/bash

### Light Theme for Sketchybar - Doom One Light
### Background matches nvim (#fafafa) for seamless integration

# Base colors - Doom One Light palette
export BLACK=0xff383a42
export WHITE=0xfffafafa
export RED=0xffe45649
export GREEN=0xff50a14f
export BLUE=0xff4078f2
export YELLOW=0xff986801
export ORANGE=0xffc18401
export MAGENTA=0xffa626a4
export CYAN=0xff0184bc
export PURPLE=0xffa626a4
export GREY=0xff9ca0a4
export LIGHT_GREY=0xffa0a1a7
export DARK_GREY=0xfff0f0f0
export TRANSPARENT=0x00000000

# Battery colors - Doom One Light status indication
export BATTERY_1=0xff50a14f  # Green - Full
export BATTERY_2=0xff986801  # Yellow - High
export BATTERY_3=0xffc18401  # Orange - Medium
export BATTERY_4=0xffe45649  # Red - Low
export BATTERY_5=0xffe45649  # Red - Critical

# General bar colors - Matches nvim background
export BAR_COLOR=0xfffafafa              # Same as nvim bg
export BAR_BORDER_COLOR=0xfff0f0f0       # bg1
export BACKGROUND_1=0xe6fafafa           # Translucent nvim bg
export BACKGROUND_2=0xfff0f0f0           # bg1
export ICON_COLOR=0xff383a42             # dark fg
export LABEL_COLOR=0xff383a42            # dark fg
export POPUP_BACKGROUND_COLOR=0xf0fafafa # nvim bg
export POPUP_BORDER_COLOR=0xff4078f2     # blue
export SHADOW_COLOR=0x40000000           # Visible shadow

# Accent colors - Doom One Light harmonious palette
export ACCENT_PRIMARY=0xff4078f2         # Blue
export ACCENT_SECONDARY=0xff50a14f       # Green
export ACCENT_TERTIARY=0xffc18401        # Orange
export ACCENT_QUATERNARY=0xffa626a4      # Purple
export ACCENT_PINK=0xffa626a4            # Magenta
export ACCENT_TEAL=0xff0184bc            # Cyan
export ACCENT_GOLD=0xff986801            # Yellow

# Specialized UI colors
export SEPARATOR_COLOR=0x809ca0a4        # grey
export HOVER_BG=0x40f0f0f0               # Hover bg1
export ACTIVE_BG=0x70d0d0d0              # Active selection

# Popup/contrast colors
export POPUP_LABEL_COLOR=0xff383a42      # dark fg
export POPUP_ICON_COLOR=0xff383a42       # dark fg
export CONTRAST_TEXT=0xff383a42          # dark fg
