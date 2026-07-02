# Sketchybar Redesign — Design Spec

**Date:** 2026-04-04  
**Scope:** `suckless/mac_os/sketchybar/`

---

## Overview

Redesign the sketchybar configuration from a plain transparent floating layout to a **Pill/Island** style with a **monochrome + single orange accent** color system. The bar remains transparent (no background fill). Each widget or logical group of widgets lives in its own floating pill.

---

## Visual Style

### Bar

- Position: top, height 32px (unchanged)
- Background: fully transparent (`0x00000000`)
- No blur

### Pill anatomy

- Border radius: `8` (rounded rectangle, not full circle — sketchybar `background.corner_radius`)
- Default pill: `background.color = 0x12ffffff` (subtle white fill), `border.color = 0x2dffffff`, `border.width = 1`
- Accent pill: `background.color = 0x26F74C00`, `border.color = 0x73F74C00`, `border.width = 1`
- Font: `BlexMono Nerd Font:Regular:13.0` (unchanged)
- Default text/icon color: `0xdddddddd`

### Color palette

| Role | Color | Usage |
|------|-------|-------|
| Default text | `0xffdddddd` | All labels/icons in normal state |
| Accent | `0xffF74C00` | Active workspace, Spotify playing, battery critical, WiFi disconnected, CPU/RAM critical |
| Warning | `0xfffab387` | CPU/RAM warning level |
| Dim | `0xff555555` | Inactive workspace labels |

---

## Layout

### Left side (left → right)

1. **Workspace switcher** — one pill per Aerospace workspace
2. **Front app** — single pill

### Right side (left → right)

1. **Spotify** — single pill (hidden when Spotify not running)
2. **Volume + WiFi** — one grouped pill with a `·` separator
3. **RAM + CPU** — one grouped pill with a `·` separator
4. **Battery** — single pill
5. **Clock** — single pill

---

## Widget Specifications

### Workspace Switcher

Replaces the single `workspace` item with a **dynamic set of per-workspace items**, one per Aerospace workspace.

- Each workspace renders as a pill
- **Active workspace:** accent pill (orange background + border), white label
- **Inactive workspace:** dim pill, `0xff555555` label
- Clicking an inactive workspace pill runs `aerospace workspace <N>` to focus it
- Subscribes to `aerospace_workspace_change` event
- Implementation: use `sketchybar --add bracket` or individual items generated per-workspace on init

### Front App

- Grey pill
- Icon from `icon_map_fn.sh` (unchanged logic)
- Label: app name
- Color: `0xffdddddd` for both icon and label

### Spotify

- **Playing:** accent pill (orange), label = `"♫ Track — Artist"`, label color `0xffF74C00`
- **Paused:** grey pill, same label, color `0xff888888`
- **Not running / stopped:** `drawing=off` (hidden entirely)
- Remove album art thumbnail (`spotify.cover`) — no longer needed in pill style
- `update_freq=2`

### Volume + WiFi (grouped pill)

Implemented as a sketchybar `bracket` grouping two items (`volume` and `wifi`) inside one pill background.

**Volume item:**
- Icon: `󰕾` with percentage label (e.g. `72%`)
- Normal state: `0xffdddddd`

**WiFi item:**
- Connected: icon `󰖩`, label = SSID or `"WiFi"`, color `0xffdddddd`
- Disconnected: icon `󰖪`, label = `"Off"`, icon + label color `0xffF74C00`
- Separator between volume and wifi: `·` rendered as a label-only spacer item inside the bracket

### RAM + CPU (grouped pill)

Implemented as a sketchybar `bracket` grouping two items (`ram` and `cpu`) inside one pill background.

The **bracket border/background** color updates to reflect the worst state of either metric:

| Threshold | Border/bg color | Text color |
|-----------|----------------|------------|
| Both < 60% | default grey | `0xffdddddd` |
| Either 60–85% | `0x1afab387` bg / `0x45fab387` border | `0xfffab387` |
| Either > 85% | `0x26F74C00` bg / `0x73F74C00` border | `0xffF74C00` |

**RAM item:**
- Label: e.g. ` 4.2G` — reads from `vm_stat` or `memory_pressure`
- `update_freq=10`

**CPU item:**
- Icon: `󰻠`, label: percentage — reads from `top -l 1` or `ps`
- `update_freq=5`

### Battery

- Normal (≥15%): grey pill, icon + `%` label, color `0xffdddddd`
- Critical (<15%): accent pill (orange), icon + `%` label, color `0xffF74C00`
- Icons: keep existing icon set from `plugins/battery.sh`
- Remove color-coded-by-level behavior (old rainbow scale) — replaced by just critical/normal

### Clock

- Grey pill, no icon
- Format: `"%a %d %b  %H:%M"` (unchanged)
- `update_freq=5`

---

## Files Changed

### Removed
- `items/spotify.sh` — `spotify.cover` item removed (no more album art)
- `plugins/spotify.sh` — remove cover/artwork logic

### Modified
- `sketchybarrc` — source new items, remove old workspace/spotify setup
- `colors.sh` — add pill color constants
- `items/workspace.sh` → replaced by `items/workspaces.sh` (multi-workspace switcher)
- `items/front_app.sh` — add pill background styling
- `items/spotify.sh` — simplify to single text item with state colors
- `items/battery.sh` — simplify to two-state (normal/critical)
- `items/clock.sh` — add pill background
- `plugins/battery.sh` — simplify color logic
- `plugins/spotify.sh` — remove artwork, add state-based color

### New
- `items/workspaces.sh` — dynamic multi-workspace pill switcher
- `items/volume.sh` — volume item inside vol+wifi bracket
- `items/wifi.sh` — wifi item inside vol+wifi bracket
- `items/ram.sh` — ram item inside ram+cpu bracket
- `items/cpu.sh` — cpu item inside ram+cpu bracket
- `plugins/volume.sh` — reads volume via `osascript`
- `plugins/wifi.sh` — reads WiFi state via `networksetup` or `ipconfig`
- `plugins/ram.sh` — reads RAM usage
- `plugins/cpu.sh` — reads CPU usage
- `plugins/workspaces.sh` — handles workspace focus change + click

---

## Bracket Implementation Pattern

Sketchybar brackets group items under a shared background. For the vol+wifi and ram+cpu groups:

```bash
sketchybar --add bracket vol_wifi_group volume separator_vw wifi \
           --set vol_wifi_group background.color=0x12ffffff \
                                background.border_color=0x2dffffff \
                                background.border_width=1 \
                                background.corner_radius=8
```

The separator item is a zero-width spacer with a `·` label and `padding_left/right` tuned to produce the visual dot separator.

---

## Out of Scope

- Theme switching (light/dark) — keeping existing `theme_change.sh` hook but not redesigning themes
- Helper binary (`helper/`) — not touched
- Any yabai integration — user uses Aerospace, not yabai
