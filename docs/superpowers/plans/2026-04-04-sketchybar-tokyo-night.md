# Sketchybar Tokyo Night Floating Pills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle Sketchybar to Tokyo Night colors with floating pill backgrounds, keeping all existing functionality intact.

**Architecture:** Color palettes live in `themes/dark.sh` and `themes/light.sh`. The `colors.sh` file sources the right theme and exports `ITEM_BG_COLOR` for pill backgrounds. Each item in `items/` gets pill background properties added. Plugin scripts get updated hardcoded colors replaced with Tokyo Night equivalents.

**Tech Stack:** Bash, Sketchybar

---

## File Map

| File | Action |
|------|--------|
| `suckless/mac_os/sketchybar/themes/dark.sh` | Replace OneDark → Tokyo Night dark |
| `suckless/mac_os/sketchybar/themes/light.sh` | Replace Doom One Light → Tokyo Night Light |
| `suckless/mac_os/sketchybar/colors.sh` | Add `ITEM_BG_COLOR`, keep transparent bar |
| `suckless/mac_os/sketchybar/items/workspace.sh` | Add pill background props |
| `suckless/mac_os/sketchybar/items/front_app.sh` | Add pill, fix hardcoded color |
| `suckless/mac_os/sketchybar/items/clock.sh` | Add pill background props |
| `suckless/mac_os/sketchybar/items/battery.sh` | Add pill background props |
| `suckless/mac_os/sketchybar/items/spotify.sh` | Add pill to `spotify.text` |
| `suckless/mac_os/sketchybar/plugins/workspace.sh` | Remove `|` from label |
| `suckless/mac_os/sketchybar/plugins/battery.sh` | Update hardcoded colors |
| `suckless/mac_os/sketchybar/plugins/theme_change.sh` | Refresh pill bg on theme switch |

---

### Task 1: Update dark theme palette

**Files:**
- Modify: `suckless/mac_os/sketchybar/themes/dark.sh`

- [ ] **Step 1: Replace the file contents**

```bash
#!/opt/homebrew/bin/bash

### Dark Theme for Sketchybar - Tokyo Night
### Background matches nvim (#1a1b26) for seamless integration

# Base colors - Tokyo Night palette
export BLACK=0xff1a1b26
export WHITE=0xffc0caf5
export RED=0xfff7768e
export GREEN=0xff9ece6a
export BLUE=0xff7aa2f7
export YELLOW=0xffe0af68
export ORANGE=0xffff9e64
export MAGENTA=0xffbb9af7
export CYAN=0xff2ac3de
export PURPLE=0xffbb9af7
export GREY=0xff565f89
export LIGHT_GREY=0xff737aa2
export DARK_GREY=0xff16161e
export TRANSPARENT=0x00000000

# Battery colors - Tokyo Night status indication
export BATTERY_1=0xff9ece6a  # Green  - Full
export BATTERY_2=0xff7aa2f7  # Blue   - Good
export BATTERY_3=0xffe0af68  # Yellow - Medium
export BATTERY_4=0xffff9e64  # Orange - Low
export BATTERY_5=0xfff7768e  # Red    - Critical

# General bar colors - Matches nvim background
export BAR_COLOR=0x00000000              # Transparent bar
export BAR_BORDER_COLOR=0xff24283b       # surface0
export BACKGROUND_1=0xe61a1b26           # Pill background (90% opacity)
export BACKGROUND_2=0xff16161e           # Darker bg
export ICON_COLOR=0xff565f89             # comment
export LABEL_COLOR=0xffc0caf5            # fg
export POPUP_BACKGROUND_COLOR=0xf01a1b26 # nvim bg
export POPUP_BORDER_COLOR=0xff7aa2f7     # blue
export SHADOW_COLOR=0x80000000           # Soft shadow

# Accent colors - Tokyo Night harmonious palette
export ACCENT_PRIMARY=0xff7aa2f7         # Blue
export ACCENT_SECONDARY=0xff9ece6a       # Green
export ACCENT_TERTIARY=0xffff9e64        # Orange
export ACCENT_QUATERNARY=0xffbb9af7      # Purple
export ACCENT_PINK=0xffff007c            # Pink
export ACCENT_TEAL=0xff2ac3de            # Cyan
export ACCENT_GOLD=0xffe0af68            # Yellow

# Specialized UI colors
export SEPARATOR_COLOR=0x60565f89        # Subtle grey
export HOVER_BG=0x4024283b               # Hover surface
export ACTIVE_BG=0x603d59a1              # Active selection

# Popup/contrast colors
export POPUP_LABEL_COLOR=0xffc0caf5      # fg
export POPUP_ICON_COLOR=0xff565f89       # comment
export CONTRAST_TEXT=0xffc0caf5          # fg
```

- [ ] **Step 2: Reload sketchybar to verify no errors**

```bash
sketchybar --reload
```

Expected: bar reloads without crashing. Colors should shift toward Tokyo Night blues/greens.

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/themes/dark.sh
git commit -m "feat(sketchybar): replace OneDark with Tokyo Night dark palette"
```

---

### Task 2: Update light theme palette

**Files:**
- Modify: `suckless/mac_os/sketchybar/themes/light.sh`

- [ ] **Step 1: Replace the file contents**

```bash
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
```

- [ ] **Step 2: Switch macOS to light mode and reload**

```bash
sketchybar --reload
```

Expected: bar switches to light-mode pill colors. Switch back to dark mode to restore.

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/themes/light.sh
git commit -m "feat(sketchybar): replace Doom One Light with Tokyo Night Light palette"
```

---

### Task 3: Update colors.sh — add ITEM_BG_COLOR

**Files:**
- Modify: `suckless/mac_os/sketchybar/colors.sh`

- [ ] **Step 1: Replace the file contents**

```bash
#!/opt/homebrew/bin/bash

# Color definitions
export WHITE=0xffffffff
export DARK_TEXT=0xff343b59
export LIGHT_TEXT=0xffc0caf5
export TRANSPARENT_TEXT=0x00ffffff

# Detect system appearance and source the matching theme
APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

if [ "$APPEARANCE" = "Dark" ]; then
	source "$CONFIG_DIR/themes/dark.sh"
	export TEXT_COLOR=$LIGHT_TEXT
	export ITEM_BG_COLOR=0xe61a1b26
else
	source "$CONFIG_DIR/themes/light.sh"
	export TEXT_COLOR=$DARK_TEXT
	export ITEM_BG_COLOR=0xe6d5d6db
fi

# Transparent bar - pills provide depth
export BAR_COLOR=0x00000000
export BACKGROUND_1=$ITEM_BG_COLOR
export APPLE=
```

- [ ] **Step 2: Reload sketchybar**

```bash
sketchybar --reload
```

Expected: no errors, bar still loads.

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/colors.sh
git commit -m "feat(sketchybar): add ITEM_BG_COLOR for pill backgrounds"
```

---

### Task 4: Add pill backgrounds to all items

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/workspace.sh`
- Modify: `suckless/mac_os/sketchybar/items/front_app.sh`
- Modify: `suckless/mac_os/sketchybar/items/clock.sh`
- Modify: `suckless/mac_os/sketchybar/items/battery.sh`
- Modify: `suckless/mac_os/sketchybar/items/spotify.sh`

- [ ] **Step 1: Update items/workspace.sh**

```bash
#!/opt/homebrew/bin/bash

workspace=(
	label="?"
	icon.drawing=on
	icon.padding_right=5
	padding_left=0
	padding_right=0
	background.drawing=on
	background.color=$ITEM_BG_COLOR
	background.corner_radius=6
	background.height=22
	script="$PLUGIN_DIR/workspace.sh"
)

sketchybar --add item workspace left \
	--set workspace "${workspace[@]}" \
	--subscribe workspace aerospace_workspace_change
```

- [ ] **Step 2: Update items/front_app.sh**

```bash
#!/bin/bash

front_app=(
	icon.drawing=on
	icon.font="sketchybar-app-font:Regular:15"
	icon.color=$ACCENT_SECONDARY
	label.color=$ACCENT_SECONDARY
	icon.padding_right=5
	icon.padding_left=7
	background.drawing=on
	background.color=$ITEM_BG_COLOR
	background.corner_radius=6
	background.height=22
	script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
```

- [ ] **Step 3: Update items/clock.sh**

```bash
#!/opt/homebrew/bin/bash

clock=(
	update_freq=5
	icon.drawing=off
	background.drawing=on
	background.color=$ITEM_BG_COLOR
	background.corner_radius=6
	background.height=22
	script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
	--set clock "${clock[@]}"
```

- [ ] **Step 4: Update items/battery.sh**

```bash
#!/opt/homebrew/bin/bash

battery=(
	update_freq=120
	icon.drawing=on
	label.drawing=on
	icon.padding_left=4
	icon.padding_right=3
	padding_left=20
	label.padding_left=0
	label.padding_right=10
	background.drawing=on
	background.color=$ITEM_BG_COLOR
	background.corner_radius=6
	background.height=22
	script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery system_woke power_source_change
```

- [ ] **Step 5: Update items/spotify.sh** — pill on `spotify.text` only; `spotify.cover` keeps its image background

```bash
#!/opt/homebrew/bin/bash

spotify_text=(
	update_freq=2
	icon.drawing=off
	icon.padding_left=0
	icon.padding_right=0
	label.drawing=on
	padding_right=0
	padding_left=0
	background.drawing=on
	background.color=$ITEM_BG_COLOR
	background.corner_radius=6
	background.height=22
	click_script="open -a Spotify"
	script="$PLUGIN_DIR/spotify.sh"
)

spotify_cover=(
	icon.drawing=off
	label.drawing=off
	background.image.scale=0.04
	background.image.drawing=on
	background.drawing=on
	background.color=0x00000000
	width=30
	padding_left=5
	padding_right=5
	click_script="open -a Spotify"
	script="$PLUGIN_DIR/spotify.sh"
)

sketchybar --add item spotify.text right \
	--set spotify.text "${spotify_text[@]}" \
	--subscribe spotify.text system_woke \
	\
	--add item spotify.cover right \
	--set spotify.cover "${spotify_cover[@]}" \
	--subscribe spotify.cover system_woke
```

- [ ] **Step 6: Reload and verify all items show pills**

```bash
sketchybar --reload
```

Expected: each item (workspace, front_app, clock, battery, spotify text) has a rounded dark pill background. Bar area between pills is fully transparent.

- [ ] **Step 7: Commit**

```bash
git add suckless/mac_os/sketchybar/items/
git commit -m "feat(sketchybar): add floating pill backgrounds to all items"
```

---

### Task 5: Remove pipe separator from workspace label

**Files:**
- Modify: `suckless/mac_os/sketchybar/plugins/workspace.sh`

- [ ] **Step 1: Update the label line**

Replace:
```bash
sketchybar --set $NAME label="$FOCUSED_WORKSPACE |" icon="󱃞" icon.font="$FONT:Regular:18" animate tanh 10
```

With:
```bash
sketchybar --set $NAME label="$FOCUSED_WORKSPACE" icon="󱃞" icon.font="$FONT:Regular:18" animate tanh 10
```

- [ ] **Step 2: Switch workspaces and verify**

Switch to a different Aerospace workspace. Expected: workspace item shows `󱃞 2` (no pipe character).

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/plugins/workspace.sh
git commit -m "fix(sketchybar): remove pipe separator from workspace label"
```

---

### Task 6: Update battery plugin colors to Tokyo Night

**Files:**
- Modify: `suckless/mac_os/sketchybar/plugins/battery.sh`

- [ ] **Step 1: Replace the color scale section**

Replace the existing color scale block:
```bash
# Diverse color scale
if    [[ $PERCENTAGE -le 10 ]]; then COLOR=0xffff5555  # red    → critical
elif  [[ $PERCENTAGE -le 25 ]]; then COLOR=0xffffb86c  # orange → low
elif  [[ $PERCENTAGE -le 50 ]]; then COLOR=0xfff1fa8c  # yellow → medium
elif  [[ $PERCENTAGE -le 75 ]]; then COLOR=0xff8be9fd  # blue  → good
else                                  COLOR=0xff50fa7b  # green   → full
fi
```

With:
```bash
# Tokyo Night color scale
if    [[ $PERCENTAGE -le 10 ]]; then COLOR=0xfff7768e  # red    → critical
elif  [[ $PERCENTAGE -le 25 ]]; then COLOR=0xffff9e64  # orange → low
elif  [[ $PERCENTAGE -le 50 ]]; then COLOR=0xffe0af68  # yellow → medium
elif  [[ $PERCENTAGE -le 75 ]]; then COLOR=0xff7aa2f7  # blue   → good
else                                  COLOR=0xff9ece6a  # green  → full
fi
```

- [ ] **Step 2: Reload and verify**

```bash
sketchybar --reload
```

Expected: battery icon and percentage text color matches Tokyo Night (green if >75%, blue if >50%, etc.).

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/plugins/battery.sh
git commit -m "feat(sketchybar): update battery colors to Tokyo Night palette"
```

---

### Task 7: Update theme_change.sh to refresh pill backgrounds on switch

**Files:**
- Modify: `suckless/mac_os/sketchybar/plugins/theme_change.sh`

- [ ] **Step 1: Replace file contents**

```bash
#!/opt/homebrew/bin/bash

# Source colors (re-detects appearance and sets ITEM_BG_COLOR)
source "$CONFIG_DIR/colors.sh"

# Update text colors
sketchybar --set '/.*/' icon.color=$TEXT_COLOR label.color=$TEXT_COLOR

# Update pill backgrounds
sketchybar --set '/.*/' background.color=$ITEM_BG_COLOR
```

- [ ] **Step 2: Test the theme switch**

Toggle macOS appearance: System Settings → Appearance → Dark/Light. Expected: bar pills smoothly switch between dark navy (`#1a1b26`) and light grey (`#d5d6db`) pill backgrounds.

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/plugins/theme_change.sh
git commit -m "feat(sketchybar): refresh pill backgrounds on macOS theme switch"
```

---

## Final Verification

- [ ] Dark mode: all items show dark navy pills, Tokyo Night accent colors
- [ ] Light mode: all items show light grey pills, dark Tokyo Night colors  
- [ ] Workspace label shows number only (no pipe)
- [ ] Battery color updates as percentage changes
- [ ] Toggling macOS appearance updates both text and pill colors
- [ ] Spotify text shows in purple pill; cover art item unaffected
