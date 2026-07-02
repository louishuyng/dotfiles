# Sketchybar Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign sketchybar from plain transparent floating items to a pill/island style with mono+orange accent coloring, adding workspace switcher, volume, WiFi, RAM, and CPU widgets.

**Architecture:** Each widget is an independent item script under `items/` with a corresponding plugin under `plugins/`. Grouped widgets (vol+wifi, ram+cpu) use sketchybar brackets to share a pill background. The main `sketchybarrc` sources items in left-to-right display order and adds brackets after all member items are registered. A shared cache dir at `/tmp/sketchybar/` lets ram and cpu plugins coordinate bracket color without a shared process.

**Tech Stack:** Sketchybar 2.x, Aerospace (window manager), bash, osascript, networksetup, vm_stat, top, pmset

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `colors.sh` | Add pill color constants |
| Modify | `sketchybarrc` | Wire all items + brackets, update defaults |
| Replace | `items/workspace.sh` → `items/workspaces.sh` | Multi-workspace pill switcher |
| New | `plugins/workspaces.sh` | Update all workspace pills on focus change |
| Modify | `items/front_app.sh` | Add pill background |
| Modify | `items/spotify.sh` | Single pill, no cover art |
| Modify | `plugins/spotify.sh` | State-based colors, remove artwork logic |
| New | `items/volume.sh` | Volume item (inside vol+wifi bracket) |
| New | `plugins/volume.sh` | Read system volume via osascript |
| New | `items/wifi.sh` | WiFi item (inside vol+wifi bracket) |
| New | `plugins/wifi.sh` | Read WiFi state via networksetup |
| New | `items/ram.sh` | RAM item (inside ram+cpu bracket) |
| New | `plugins/ram.sh` | Read RAM usage via vm_stat, update bracket color |
| New | `items/cpu.sh` | CPU item (inside ram+cpu bracket) |
| New | `plugins/cpu.sh` | Read CPU usage via top, update bracket color |
| Modify | `items/battery.sh` | Two-state pill (normal/critical) |
| Modify | `plugins/battery.sh` | Simplify to critical/normal only |
| Modify | `items/clock.sh` | Add pill background |
| Delete | `items/spotify.sh` cover item | Removed (no album art) |

---

## Task 1: Add pill color constants to colors.sh

**Files:**
- Modify: `suckless/mac_os/sketchybar/colors.sh`

- [ ] **Step 1: Open colors.sh and append pill constants**

Replace the entire file with:

```bash
#!/opt/homebrew/bin/bash

# ── Text colors ───────────────────────────────────────────────
export TEXT_DEFAULT=0xffdddddd   # white-grey — all normal labels
export TEXT_DIM=0xff555555       # dimmed — inactive workspaces
export TEXT_ACCENT=0xffF74C00   # orange — active/critical state
export TEXT_WARN=0xfffab387     # warm orange — warning state

# ── Pill backgrounds & borders ────────────────────────────────
export PILL_BG=0x12ffffff        # subtle white fill
export PILL_BORDER=0x2dffffff    # faint white border

export PILL_ACCENT_BG=0x26F74C00
export PILL_ACCENT_BORDER=0x73F74C00

export PILL_WARN_BG=0x1afab387
export PILL_WARN_BORDER=0x45fab387

export PILL_DIM_BG=0x08ffffff    # inactive workspace background
export PILL_DIM_BORDER=0x18ffffff

# ── Bar ───────────────────────────────────────────────────────
export BAR_COLOR=0x00000000
```

- [ ] **Step 2: Syntax check**

```bash
bash -n suckless/mac_os/sketchybar/colors.sh
```

Expected: no output (no errors)

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/colors.sh
git commit -m "feat(sketchybar): add pill color constants to colors.sh"
```

---

## Task 2: Update sketchybarrc — defaults and bar config

**Files:**
- Modify: `suckless/mac_os/sketchybar/sketchybarrc`

This task rewrites the defaults block and bar config. Item sourcing is updated in the final task (Task 13) once all items exist.

- [ ] **Step 1: Rewrite sketchybarrc with new defaults**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
ITEM_DIR="$CONFIG_DIR/items"

##### Bar Appearance #####
sketchybar --bar position=top height=32 \
                 color=$BAR_COLOR \
                 blur_radius=0 \
                 padding_left=10 \
                 padding_right=10

##### Changing Defaults #####
default=(
    icon.font="BlexMono Nerd Font:Regular:13.0"
    icon.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    label.color=$TEXT_DEFAULT
    padding_left=4
    padding_right=4
    background.color=$PILL_BG
    background.border_color=$PILL_BORDER
    background.border_width=1
    background.corner_radius=8
    background.height=24
    background.drawing=on
)
sketchybar --default "${default[@]}"

##### Events #####
sketchybar --add event aerospace_workspace_change
sketchybar --add event theme_change "AppleInterfaceThemeChangedNotification"
sketchybar --add item theme_listener left \
           --set theme_listener script="$PLUGIN_DIR/theme_change.sh" \
                                drawing=off \
           --subscribe theme_listener theme_change

##### Items — sourced below in display order #####
# LEFT
source "$ITEM_DIR/workspaces.sh"
source "$ITEM_DIR/front_app.sh"

# RIGHT
source "$ITEM_DIR/spotify.sh"
source "$ITEM_DIR/volume.sh"
source "$ITEM_DIR/wifi.sh"
source "$ITEM_DIR/ram.sh"
source "$ITEM_DIR/cpu.sh"
source "$ITEM_DIR/battery.sh"
source "$ITEM_DIR/clock.sh"

##### Brackets (must come after member items) #####
sketchybar --add bracket vol_wifi_group volume separator_vw wifi \
           --set vol_wifi_group \
                 background.color=$PILL_BG \
                 background.border_color=$PILL_BORDER \
                 background.border_width=1 \
                 background.corner_radius=8 \
                 background.height=24 \
                 background.drawing=on

sketchybar --add bracket ram_cpu_group ram separator_rc cpu \
           --set ram_cpu_group \
                 background.color=$PILL_BG \
                 background.border_color=$PILL_BORDER \
                 background.border_width=1 \
                 background.corner_radius=8 \
                 background.height=24 \
                 background.drawing=on

##### Force all scripts to run the first time #####
sketchybar --update
```

- [ ] **Step 2: Syntax check**

```bash
bash -n suckless/mac_os/sketchybar/sketchybarrc
```

Expected: no output

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/sketchybarrc
git commit -m "feat(sketchybar): update defaults to pill style with corner_radius"
```

---

## Task 3: Workspace switcher — item + plugin

**Files:**
- Create: `suckless/mac_os/sketchybar/items/workspaces.sh`
- Create: `suckless/mac_os/sketchybar/plugins/workspaces.sh`
- Delete: `suckless/mac_os/sketchybar/items/workspace.sh`

The switcher uses a hidden `workspace_listener` item to receive the Aerospace event and update all workspace pills.

- [ ] **Step 1: Create items/workspaces.sh**

```bash
#!/opt/homebrew/bin/bash

# Dynamically create one pill per Aerospace workspace
WORKSPACES=($(aerospace list-workspaces --all))

for ws in "${WORKSPACES[@]}"; do
    sketchybar --add item "workspace.$ws" left \
               --set "workspace.$ws" \
                     label="$ws" \
                     icon.drawing=off \
                     background.color=$PILL_DIM_BG \
                     background.border_color=$PILL_DIM_BORDER \
                     background.border_width=1 \
                     background.corner_radius=8 \
                     background.height=24 \
                     background.drawing=on \
                     label.color=$TEXT_DIM \
                     label.font="BlexMono Nerd Font:Regular:13.0" \
                     padding_left=3 \
                     padding_right=3 \
                     click_script="aerospace workspace $ws"
done

# Hidden listener that receives the event and updates all pills
sketchybar --add item workspace_listener left \
           --set workspace_listener \
                 drawing=off \
                 script="$PLUGIN_DIR/workspaces.sh" \
           --subscribe workspace_listener aerospace_workspace_change
```

- [ ] **Step 2: Create plugins/workspaces.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

FOCUSED=$(aerospace list-workspaces --focused)
WORKSPACES=($(aerospace list-workspaces --all))

for ws in "${WORKSPACES[@]}"; do
    if [ "$ws" = "$FOCUSED" ]; then
        sketchybar --set "workspace.$ws" \
                   background.color=$PILL_ACCENT_BG \
                   background.border_color=$PILL_ACCENT_BORDER \
                   label.color=$TEXT_DEFAULT
    else
        sketchybar --set "workspace.$ws" \
                   background.color=$PILL_DIM_BG \
                   background.border_color=$PILL_DIM_BORDER \
                   label.color=$TEXT_DIM
    fi
done
```

- [ ] **Step 3: Make plugin executable**

```bash
chmod +x suckless/mac_os/sketchybar/items/workspaces.sh
chmod +x suckless/mac_os/sketchybar/plugins/workspaces.sh
```

- [ ] **Step 4: Syntax check both files**

```bash
bash -n suckless/mac_os/sketchybar/items/workspaces.sh
bash -n suckless/mac_os/sketchybar/plugins/workspaces.sh
```

Expected: no output

- [ ] **Step 5: Remove old workspace item**

```bash
git rm suckless/mac_os/sketchybar/items/workspace.sh
```

- [ ] **Step 6: Commit**

```bash
git add suckless/mac_os/sketchybar/items/workspaces.sh \
        suckless/mac_os/sketchybar/plugins/workspaces.sh
git commit -m "feat(sketchybar): replace workspace with multi-pill switcher"
```

---

## Task 4: Front app — add pill background

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/front_app.sh`

- [ ] **Step 1: Rewrite items/front_app.sh**

```bash
#!/bin/bash

front_app=(
    icon.drawing=on
    icon.font="sketchybar-app-font:Regular:15"
    icon.color=$TEXT_DEFAULT
    label.color=$TEXT_DEFAULT
    icon.padding_right=5
    icon.padding_left=7
    background.color=$PILL_BG
    background.border_color=$PILL_BORDER
    background.border_width=1
    background.corner_radius=8
    background.height=24
    background.drawing=on
    script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
    --set front_app "${front_app[@]}" \
    --subscribe front_app front_app_switched
```

- [ ] **Step 2: Syntax check**

```bash
bash -n suckless/mac_os/sketchybar/items/front_app.sh
```

Expected: no output

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/items/front_app.sh
git commit -m "feat(sketchybar): add pill background to front_app"
```

---

## Task 5: Spotify — single pill with state colors

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/spotify.sh`
- Modify: `suckless/mac_os/sketchybar/plugins/spotify.sh`

- [ ] **Step 1: Rewrite items/spotify.sh**

```bash
#!/opt/homebrew/bin/bash

spotify=(
    update_freq=2
    icon.drawing=off
    label.drawing=on
    label.font="BlexMono Nerd Font:Regular:13.0"
    label.color=$TEXT_DEFAULT
    padding_left=4
    padding_right=4
    background.color=$PILL_BG
    background.border_color=$PILL_BORDER
    background.border_width=1
    background.corner_radius=8
    background.height=24
    background.drawing=off
    click_script="open -a Spotify"
    script="$PLUGIN_DIR/spotify.sh"
)

sketchybar --add item spotify right \
    --set spotify "${spotify[@]}" \
    --subscribe spotify system_woke
```

- [ ] **Step 2: Rewrite plugins/spotify.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# Hide if Spotify not running
if ! pgrep -x "Spotify" >/dev/null; then
    sketchybar --set spotify drawing=off background.drawing=off
    exit 0
fi

STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
    sketchybar --set spotify drawing=off background.drawing=off
    exit 0
fi

TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
LABEL="♫ $TRACK — $ARTIST"

if [[ "$STATE" == "playing" ]]; then
    sketchybar --set spotify \
               drawing=on \
               background.drawing=on \
               background.color=$PILL_ACCENT_BG \
               background.border_color=$PILL_ACCENT_BORDER \
               label="$LABEL" \
               label.color=$TEXT_ACCENT
else
    # Paused
    sketchybar --set spotify \
               drawing=on \
               background.drawing=on \
               background.color=$PILL_BG \
               background.border_color=$PILL_BORDER \
               label="$LABEL" \
               label.color=0xff888888
fi
```

- [ ] **Step 3: Make executable and syntax check**

```bash
chmod +x suckless/mac_os/sketchybar/items/spotify.sh
chmod +x suckless/mac_os/sketchybar/plugins/spotify.sh
bash -n suckless/mac_os/sketchybar/items/spotify.sh
bash -n suckless/mac_os/sketchybar/plugins/spotify.sh
```

Expected: no output

- [ ] **Step 4: Commit**

```bash
git add suckless/mac_os/sketchybar/items/spotify.sh \
        suckless/mac_os/sketchybar/plugins/spotify.sh
git commit -m "feat(sketchybar): redesign spotify as single state-colored pill"
```

---

## Task 6: Volume item + plugin

**Files:**
- Create: `suckless/mac_os/sketchybar/items/volume.sh`
- Create: `suckless/mac_os/sketchybar/plugins/volume.sh`

These items will be members of the `vol_wifi_group` bracket (bracket added in sketchybarrc, Task 2). Their own `background.drawing` must be `off` so only the bracket pill shows.

- [ ] **Step 1: Create items/volume.sh**

```bash
#!/opt/homebrew/bin/bash

volume=(
    update_freq=5
    icon="󰕾"
    icon.font="BlexMono Nerd Font:Regular:14.0"
    icon.color=$TEXT_DEFAULT
    icon.padding_left=8
    icon.padding_right=4
    label.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    padding_left=0
    padding_right=0
    background.drawing=off
    script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add item volume right \
    --set volume "${volume[@]}"
```

- [ ] **Step 2: Create plugins/volume.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

VOL=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ "$MUTED" == "true" ]]; then
    sketchybar --set volume icon="󰖁" label="Mute" icon.color=$TEXT_DIM label.color=$TEXT_DIM
else
    sketchybar --set volume icon="󰕾" label="${VOL}%" icon.color=$TEXT_DEFAULT label.color=$TEXT_DEFAULT
fi
```

- [ ] **Step 3: Create the separator item for vol+wifi bracket**

Add to `items/volume.sh` after the volume item (the separator lives between volume and wifi inside the bracket):

```bash
# Dot separator inside vol_wifi_group bracket
sketchybar --add item separator_vw right \
           --set separator_vw \
                 icon.drawing=off \
                 label="·" \
                 label.color=0x44ffffff \
                 label.font="BlexMono Nerd Font:Regular:13.0" \
                 padding_left=0 \
                 padding_right=0 \
                 background.drawing=off
```

- [ ] **Step 4: Make executable and syntax check**

```bash
chmod +x suckless/mac_os/sketchybar/items/volume.sh
chmod +x suckless/mac_os/sketchybar/plugins/volume.sh
bash -n suckless/mac_os/sketchybar/items/volume.sh
bash -n suckless/mac_os/sketchybar/plugins/volume.sh
```

Expected: no output

- [ ] **Step 5: Commit**

```bash
git add suckless/mac_os/sketchybar/items/volume.sh \
        suckless/mac_os/sketchybar/plugins/volume.sh
git commit -m "feat(sketchybar): add volume item and plugin"
```

---

## Task 7: WiFi item + plugin

**Files:**
- Create: `suckless/mac_os/sketchybar/items/wifi.sh`
- Create: `suckless/mac_os/sketchybar/plugins/wifi.sh`

- [ ] **Step 1: Create items/wifi.sh**

```bash
#!/opt/homebrew/bin/bash

wifi=(
    update_freq=10
    icon="󰖩"
    icon.font="BlexMono Nerd Font:Regular:14.0"
    icon.color=$TEXT_DEFAULT
    icon.padding_left=4
    icon.padding_right=4
    label.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    label.padding_right=8
    padding_left=0
    padding_right=0
    background.drawing=off
    script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
    --set wifi "${wifi[@]}"
```

- [ ] **Step 2: Create plugins/wifi.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# networksetup returns "Current Wi-Fi Network: <SSID>" when connected
# or "You are not associated with an AirPort network." when disconnected
RESULT=$(networksetup -getairportnetwork en0 2>/dev/null)

if echo "$RESULT" | grep -q "You are not associated"; then
    sketchybar --set wifi \
               icon="󰖪" \
               label="Off" \
               icon.color=$TEXT_ACCENT \
               label.color=$TEXT_ACCENT
else
    SSID=$(echo "$RESULT" | sed 's/Current Wi-Fi Network: //')
    sketchybar --set wifi \
               icon="󰖩" \
               label="$SSID" \
               icon.color=$TEXT_DEFAULT \
               label.color=$TEXT_DEFAULT
fi
```

- [ ] **Step 3: Make executable and syntax check**

```bash
chmod +x suckless/mac_os/sketchybar/items/wifi.sh
chmod +x suckless/mac_os/sketchybar/plugins/wifi.sh
bash -n suckless/mac_os/sketchybar/items/wifi.sh
bash -n suckless/mac_os/sketchybar/plugins/wifi.sh
```

Expected: no output

- [ ] **Step 4: Commit**

```bash
git add suckless/mac_os/sketchybar/items/wifi.sh \
        suckless/mac_os/sketchybar/plugins/wifi.sh
git commit -m "feat(sketchybar): add wifi item and plugin"
```

---

## Task 8: RAM item + plugin

**Files:**
- Create: `suckless/mac_os/sketchybar/items/ram.sh`
- Create: `suckless/mac_os/sketchybar/plugins/ram.sh`

The plugin writes RAM% to `/tmp/sketchybar/ram_pct` so the CPU plugin can read it when updating the bracket color.

- [ ] **Step 1: Create items/ram.sh**

```bash
#!/opt/homebrew/bin/bash

ram=(
    update_freq=10
    icon=""
    icon.font="BlexMono Nerd Font:Regular:14.0"
    icon.color=$TEXT_DEFAULT
    icon.padding_left=8
    icon.padding_right=4
    label.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    padding_left=0
    padding_right=0
    background.drawing=off
    script="$PLUGIN_DIR/ram.sh"
)

sketchybar --add item ram right \
    --set ram "${ram[@]}"

# Dot separator inside ram_cpu_group bracket
sketchybar --add item separator_rc right \
           --set separator_rc \
                 icon.drawing=off \
                 label="·" \
                 label.color=0x44ffffff \
                 label.font="BlexMono Nerd Font:Regular:13.0" \
                 padding_left=0 \
                 padding_right=0 \
                 background.drawing=off
```

- [ ] **Step 2: Create plugins/ram.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

CACHE_DIR="/tmp/sketchybar"
mkdir -p "$CACHE_DIR"

# Calculate used RAM in GB and as a percentage
TOTAL_BYTES=$(sysctl -n hw.memsize)
PAGE_SIZE=$(pagesize)
VM=$(vm_stat)

ACTIVE=$(echo "$VM"   | awk '/Pages active/    {gsub(/\./,"",$3); print $3}')
WIRED=$(echo "$VM"    | awk '/Pages wired down/ {gsub(/\./,"",$4); print $4}')
COMPRESSED=$(echo "$VM" | awk '/Pages occupied by compressor/ {gsub(/\./,"",$5); print $5}')

USED_BYTES=$(( (ACTIVE + WIRED + COMPRESSED) * PAGE_SIZE ))
USED_GB=$(echo "scale=1; $USED_BYTES / 1073741824" | bc)
PCT=$(echo "scale=0; $USED_BYTES * 100 / $TOTAL_BYTES" | bc)

# Cache RAM % for CPU plugin to read
echo "$PCT" > "$CACHE_DIR/ram_pct"

# Read CPU % from cache (written by cpu plugin)
CPU_PCT=$(cat "$CACHE_DIR/cpu_pct" 2>/dev/null || echo "0")

# Determine worst state
WORST=$(( PCT > CPU_PCT ? PCT : CPU_PCT ))

if   (( WORST > 85 )); then
    COLOR=$TEXT_ACCENT
    BRACKET_BG=$PILL_ACCENT_BG
    BRACKET_BORDER=$PILL_ACCENT_BORDER
elif (( WORST > 60 )); then
    COLOR=$TEXT_WARN
    BRACKET_BG=$PILL_WARN_BG
    BRACKET_BORDER=$PILL_WARN_BORDER
else
    COLOR=$TEXT_DEFAULT
    BRACKET_BG=$PILL_BG
    BRACKET_BORDER=$PILL_BORDER
fi

sketchybar --set ram label="${USED_GB}G" label.color=$COLOR icon.color=$COLOR
sketchybar --set ram_cpu_group \
           background.color=$BRACKET_BG \
           background.border_color=$BRACKET_BORDER
```

- [ ] **Step 3: Make executable and syntax check**

```bash
chmod +x suckless/mac_os/sketchybar/items/ram.sh
chmod +x suckless/mac_os/sketchybar/plugins/ram.sh
bash -n suckless/mac_os/sketchybar/items/ram.sh
bash -n suckless/mac_os/sketchybar/plugins/ram.sh
```

Expected: no output

- [ ] **Step 4: Commit**

```bash
git add suckless/mac_os/sketchybar/items/ram.sh \
        suckless/mac_os/sketchybar/plugins/ram.sh
git commit -m "feat(sketchybar): add RAM item and plugin with bracket color coordination"
```

---

## Task 9: CPU item + plugin

**Files:**
- Create: `suckless/mac_os/sketchybar/items/cpu.sh`
- Create: `suckless/mac_os/sketchybar/plugins/cpu.sh`

- [ ] **Step 1: Create items/cpu.sh**

```bash
#!/opt/homebrew/bin/bash

cpu=(
    update_freq=5
    icon="󰻠"
    icon.font="BlexMono Nerd Font:Regular:14.0"
    icon.color=$TEXT_DEFAULT
    icon.padding_left=4
    icon.padding_right=4
    label.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    label.padding_right=8
    padding_left=0
    padding_right=0
    background.drawing=off
    script="$PLUGIN_DIR/cpu.sh"
)

sketchybar --add item cpu right \
    --set cpu "${cpu[@]}"
```

- [ ] **Step 2: Create plugins/cpu.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

CACHE_DIR="/tmp/sketchybar"
mkdir -p "$CACHE_DIR"

# Sum all process CPU% — works on Apple Silicon and Intel
PCT=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

# Clamp to 100 for display
(( PCT > 100 )) && PCT=100

# Cache CPU % for RAM plugin to read
echo "$PCT" > "$CACHE_DIR/cpu_pct"

# Read RAM % from cache (written by ram plugin)
RAM_PCT=$(cat "$CACHE_DIR/ram_pct" 2>/dev/null || echo "0")

# Determine worst state
WORST=$(( PCT > RAM_PCT ? PCT : RAM_PCT ))

if   (( WORST > 85 )); then
    COLOR=$TEXT_ACCENT
    BRACKET_BG=$PILL_ACCENT_BG
    BRACKET_BORDER=$PILL_ACCENT_BORDER
elif (( WORST > 60 )); then
    COLOR=$TEXT_WARN
    BRACKET_BG=$PILL_WARN_BG
    BRACKET_BORDER=$PILL_WARN_BORDER
else
    COLOR=$TEXT_DEFAULT
    BRACKET_BG=$PILL_BG
    BRACKET_BORDER=$PILL_BORDER
fi

sketchybar --set cpu label="${PCT}%" label.color=$COLOR icon.color=$COLOR
sketchybar --set ram_cpu_group \
           background.color=$BRACKET_BG \
           background.border_color=$BRACKET_BORDER
```

- [ ] **Step 3: Make executable and syntax check**

```bash
chmod +x suckless/mac_os/sketchybar/items/cpu.sh
chmod +x suckless/mac_os/sketchybar/plugins/cpu.sh
bash -n suckless/mac_os/sketchybar/items/cpu.sh
bash -n suckless/mac_os/sketchybar/plugins/cpu.sh
```

Expected: no output

- [ ] **Step 4: Commit**

```bash
git add suckless/mac_os/sketchybar/items/cpu.sh \
        suckless/mac_os/sketchybar/plugins/cpu.sh
git commit -m "feat(sketchybar): add CPU item and plugin with bracket color coordination"
```

---

## Task 10: Battery — simplify to two-state pill

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/battery.sh`
- Modify: `suckless/mac_os/sketchybar/plugins/battery.sh`

- [ ] **Step 1: Rewrite items/battery.sh**

```bash
#!/opt/homebrew/bin/bash

battery=(
    update_freq=120
    icon.drawing=on
    icon.font="BlexMono Nerd Font:Regular:16.0"
    icon.color=$TEXT_DEFAULT
    icon.padding_left=8
    icon.padding_right=4
    label.drawing=on
    label.color=$TEXT_DEFAULT
    label.padding_right=8
    padding_left=4
    background.color=$PILL_BG
    background.border_color=$PILL_BORDER
    background.border_width=1
    background.corner_radius=8
    background.height=24
    background.drawing=on
    script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
    --set battery "${battery[@]}" \
    --subscribe battery system_woke power_source_change
```

- [ ] **Step 2: Rewrite plugins/battery.sh**

```bash
#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ -z "$PERCENTAGE" ]]; then
    exit 0
fi

# Icon selection
if [[ -n "$CHARGING" ]]; then
    ICON=""
    FONT_SIZE=15
elif [[ $PERCENTAGE -le 10 ]]; then ICON="󰂎"; FONT_SIZE=16
elif [[ $PERCENTAGE -le 20 ]]; then ICON="󱊡"; FONT_SIZE=16
elif [[ $PERCENTAGE -le 30 ]]; then ICON="󱊡"; FONT_SIZE=16
elif [[ $PERCENTAGE -le 50 ]]; then ICON="󱊢"; FONT_SIZE=16
elif [[ $PERCENTAGE -le 80 ]]; then ICON="󱊢"; FONT_SIZE=16
else                                ICON="󱊣"; FONT_SIZE=16
fi

# Two-state coloring: critical (<15%) = accent, otherwise default
if [[ $PERCENTAGE -le 15 && -z "$CHARGING" ]]; then
    sketchybar --set battery \
               icon="$ICON" \
               icon.font="BlexMono Nerd Font:Regular:$FONT_SIZE" \
               icon.color=$TEXT_ACCENT \
               label="${PERCENTAGE}%" \
               label.color=$TEXT_ACCENT \
               background.color=$PILL_ACCENT_BG \
               background.border_color=$PILL_ACCENT_BORDER
else
    sketchybar --set battery \
               icon="$ICON" \
               icon.font="BlexMono Nerd Font:Regular:$FONT_SIZE" \
               icon.color=$TEXT_DEFAULT \
               label="${PERCENTAGE}%" \
               label.color=$TEXT_DEFAULT \
               background.color=$PILL_BG \
               background.border_color=$PILL_BORDER
fi
```

- [ ] **Step 3: Syntax check**

```bash
bash -n suckless/mac_os/sketchybar/items/battery.sh
bash -n suckless/mac_os/sketchybar/plugins/battery.sh
```

Expected: no output

- [ ] **Step 4: Commit**

```bash
git add suckless/mac_os/sketchybar/items/battery.sh \
        suckless/mac_os/sketchybar/plugins/battery.sh
git commit -m "feat(sketchybar): simplify battery to two-state pill (normal/critical)"
```

---

## Task 11: Clock — add pill background

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/clock.sh`

Plugin (`plugins/clock.sh`) is unchanged.

- [ ] **Step 1: Rewrite items/clock.sh**

```bash
#!/opt/homebrew/bin/bash

clock=(
    update_freq=5
    icon.drawing=off
    label.color=$TEXT_DEFAULT
    label.font="BlexMono Nerd Font:Regular:13.0"
    label.padding_left=8
    label.padding_right=8
    padding_left=4
    background.color=$PILL_BG
    background.border_color=$PILL_BORDER
    background.border_width=1
    background.corner_radius=8
    background.height=24
    background.drawing=on
    script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
    --set clock "${clock[@]}"
```

- [ ] **Step 2: Syntax check**

```bash
bash -n suckless/mac_os/sketchybar/items/clock.sh
```

Expected: no output

- [ ] **Step 3: Commit**

```bash
git add suckless/mac_os/sketchybar/items/clock.sh
git commit -m "feat(sketchybar): add pill background to clock"
```

---

## Task 12: Clean up and reload

**Files:**
- Delete: old `items/workspace.sh` (already done in Task 3 if not yet committed)
- Verify: all item files sourced in `sketchybarrc` exist

- [ ] **Step 1: Verify all sourced files exist**

```bash
ls suckless/mac_os/sketchybar/items/
```

Expected to see: `workspaces.sh  front_app.sh  spotify.sh  volume.sh  wifi.sh  ram.sh  cpu.sh  battery.sh  clock.sh`

```bash
ls suckless/mac_os/sketchybar/plugins/
```

Expected to see: `workspaces.sh  front_app.sh  spotify.sh  volume.sh  wifi.sh  ram.sh  cpu.sh  battery.sh  clock.sh  theme_change.sh  icon_map_fn.sh`

- [ ] **Step 2: Full syntax check on sketchybarrc**

```bash
bash -n suckless/mac_os/sketchybar/sketchybarrc
```

Expected: no output

- [ ] **Step 3: Reload sketchybar**

```bash
sketchybar --reload
```

Then visually verify:
- Left side: workspace number pills appear (active = orange, inactive = dim grey)
- Clicking an inactive workspace pill switches to it
- Front app shows current app name with pill border
- Right side: Spotify pill (orange if playing, grey if paused, hidden if stopped)
- Volume + WiFi share one pill with `·` separator
- RAM + CPU share one pill with `·` separator, color changes under load
- Battery shows percentage with orange pill when <15%
- Clock shows date + time in a pill

- [ ] **Step 4: Add .superpowers to .gitignore if not already present**

```bash
grep -q ".superpowers" suckless/mac_os/sketchybar/.gitignore 2>/dev/null \
  || echo ".superpowers/" >> /Users/louishuyng/.dotfiles/.gitignore
```

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat(sketchybar): complete pill/island redesign with all widgets"
```
