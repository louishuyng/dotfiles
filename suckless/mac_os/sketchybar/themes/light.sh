#!/opt/homebrew/bin/bash

### Light Theme for Sketchybar - Tokyo Night Light
### Background matches nvim (#d5d6db) for seamless integration

# Base colors - Tokyo Night Light palette
export BLACK=0xff343b59
export WHITE=0xffd5d6db
export RED=0xff8c4351
export GREEN=0xff485e30
export BLUE=0xff343b59
export YELLOW=0xff8f5e15
export ORANGE=0xff965027
export MAGENTA=0xff5a4a78
export CYAN=0xff0f4b6e
export PURPLE=0xff5a4a78
export GREY=0xff565f89
export LIGHT_GREY=0xff9699a3
export DARK_GREY=0xffe9e9ed
export TRANSPARENT=0x00000000

# Battery colors - Tokyo Night Light status indication
export BATTERY_1=0xff485e30  # Green  - Full
export BATTERY_2=0xff343b59  # Blue   - Good
export BATTERY_3=0xff8f5e15  # Yellow - Medium
export BATTERY_4=0xff965027  # Orange - Low
export BATTERY_5=0xff8c4351  # Red    - Critical

# General bar colors - Matches nvim background
export BAR_COLOR=0x00000000              # Transparent bar
export BAR_BORDER_COLOR=0xffe9e9ed       # surface
export BACKGROUND_1=0xe6d5d6db           # Pill background (90% opacity)
export BACKGROUND_2=0xffe9e9ed           # lighter bg
export ICON_COLOR=0xff343b59             # dark fg
export LABEL_COLOR=0xff343b59            # dark fg
export POPUP_BACKGROUND_COLOR=0xf0d5d6db # nvim bg
export POPUP_BORDER_COLOR=0xff343b59     # blue-dark
export SHADOW_COLOR=0x40000000           # Visible shadow

# Accent colors - Tokyo Night Light harmonious palette
export ACCENT_PRIMARY=0xff343b59         # Blue dark
export ACCENT_SECONDARY=0xff485e30       # Green dark
export ACCENT_TERTIARY=0xff965027        # Orange dark
export ACCENT_QUATERNARY=0xff5a4a78      # Purple dark
export ACCENT_PINK=0xff5a4a78            # Magenta dark
export ACCENT_TEAL=0xff0f4b6e            # Cyan dark
export ACCENT_GOLD=0xff8f5e15            # Yellow dark

# Specialized UI colors
export SEPARATOR_COLOR=0x809699a3        # grey
export HOVER_BG=0x40e9e9ed               # Hover bg
export ACTIVE_BG=0x70d0d0d8              # Active selection

# Popup/contrast colors
export POPUP_LABEL_COLOR=0xff343b59      # dark fg
export POPUP_ICON_COLOR=0xff343b59       # dark fg
export CONTRAST_TEXT=0xff343b59          # dark fg
