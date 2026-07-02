# Sketchybar Tokyo Night Floating Pills

**Date:** 2026-04-04
**Status:** Approved

## Summary

Restyle the existing Sketchybar configuration to the Tokyo Night color family with a floating-pill visual style. All items, scripts, and subscriptions remain unchanged — only colors and per-item backgrounds are updated.

## Visual Style

**Floating Pills:** The bar background is fully transparent (`0x00000000`). Each item renders its own pill-shaped background (`corner_radius=6`, `height=22`, `color=0xe61a1b26` dark / `0xe6d5d6db` light). This creates the appearance of floating labels over the wallpaper with no visible bar.

Dark and light mode previews:

```
Dark:   [󱃞 1]  [ iTerm2]  ...  [♫ Lofi Chill]  [󱊣 85%]  [12:34]
Light:  [󱃞 1]  [ iTerm2]  ...  [♫ Lofi Chill]  [󱊣 85%]  [12:34]
```

No `|` separator in workspace label — pills provide visual separation.

## Color Palettes

### Dark — Tokyo Night (`themes/dark.sh`)

| Role              | Color     | Hex       |
|-------------------|-----------|-----------|
| Pill background   | navy      | `#1a1b26` (alpha e6) |
| Foreground        | lavender  | `#c0caf5` |
| Blue (workspace)  | blue      | `#7aa2f7` |
| Green (app, bat)  | green     | `#9ece6a` |
| Purple (spotify)  | purple    | `#bb9af7` |
| Yellow            | yellow    | `#e0af68` |
| Orange            | orange    | `#ff9e64` |
| Red (critical)    | red       | `#f7768e` |
| Dim (clock)       | comment   | `#565f89` |
| Battery critical  | red       | `#f7768e` |
| Battery low       | orange    | `#ff9e64` |
| Battery medium    | yellow    | `#e0af68` |
| Battery good      | blue      | `#7aa2f7` |
| Battery full      | green     | `#9ece6a` |

### Light — Tokyo Night Light (`themes/light.sh`)

| Role              | Color     | Hex       |
|-------------------|-----------|-----------|
| Pill background   | light grey| `#d5d6db` (alpha e6) |
| Foreground        | dark navy | `#343b59` |
| Blue (workspace)  | dark blue | `#343b59` |
| Green (app, bat)  | dark green| `#485e30` |
| Purple (spotify)  | dark purple| `#5a4a78` |
| Yellow            | dark yellow| `#8f5e15` |
| Orange            | dark orange| `#965027` |
| Red (critical)    | dark red  | `#8c4351` |
| Dim (clock)       | grey      | `#565f89` |

## Files to Modify

### `themes/dark.sh`
Replace the OneDark palette with the Tokyo Night dark palette above. Keep all existing exported variable names (`BLACK`, `WHITE`, `RED`, `GREEN`, `BLUE`, `YELLOW`, `ORANGE`, `MAGENTA`, `CYAN`, `PURPLE`, `GREY`, `TRANSPARENT`, `BAR_COLOR`, `BACKGROUND_1`, `BACKGROUND_2`, `ICON_COLOR`, `LABEL_COLOR`, `POPUP_*`, `ACCENT_*`, `BATTERY_*`, `SHADOW_COLOR`, `SEPARATOR_COLOR`, `HOVER_BG`, `ACTIVE_BG`).

### `themes/light.sh`
Replace the Doom One Light palette with the Tokyo Night Light palette. Same variable names.

### `colors.sh`
- Set `BAR_COLOR=0x00000000` (transparent)
- Set `ITEM_BG_COLOR` to pill color: `0xe61a1b26` (dark) or `0xe6d5d6db` (light) based on appearance
- Keep existing appearance detection logic

### `items/workspace.sh`
- Add `background.drawing=on`, `background.color=$ITEM_BG_COLOR`, `background.corner_radius=6`, `background.height=22`
- Keep existing icon (`󱃞`), icon font, and label script
- Remove `|` from the label in `plugins/workspace.sh`

### `items/front_app.sh`
- Add pill background properties
- Replace hardcoded `0xffA0C980` color with `$ACCENT_SECONDARY` variable

### `items/clock.sh`
- Add pill background properties
- Label color uses `$LABEL_COLOR` (dim comment color)

### `items/battery.sh`
- Add pill background properties
- Keep per-level color logic in plugin

### `items/spotify.sh` (both `spotify.text` and `spotify.cover`)
- Add pill background to `spotify.text`
- `spotify.cover` keeps its existing image background setup

### `plugins/workspace.sh`
- Change `label="$FOCUSED_WORKSPACE |"` → `label="$FOCUSED_WORKSPACE"` (no pipe)

### `plugins/battery.sh`
- Replace hardcoded Dracula/OneDark colors with Tokyo Night equivalents:
  - Critical (≤10%): `0xfff7768e`
  - Low (≤25%): `0xffff9e64`
  - Medium (≤50%): `0xffe0af68`
  - Good (≤75%): `0xff7aa2f7`
  - Full: `0xff9ece6a`

### `plugins/theme_change.sh`
- After sourcing `colors.sh`, also update pill background colors across all items:
  ```bash
  sketchybar --set '/.*/' background.color=$ITEM_BG_COLOR
  ```

## Out of Scope

- No new items or plugins
- No layout changes (left/right positioning unchanged)
- No font changes
- No spotify cover art changes
- No changes to event subscriptions or update frequencies
