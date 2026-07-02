# Sketchybar — Hyprland Minimal-Flat Restyle

**Date:** 2026-05-14
**Scope:** `suckless/mac_os/sketchybar/`

## Goal

Restyle the existing sketchybar to match a minimal, edge-to-edge Hyprland-rice aesthetic in Catppuccin Mocha (dark) and Catppuccin Latte (light), keeping the current item set and Aerospace workspace integration.

## Non-goals

- No layout reflow (no floating bar, no rounded pills, no per-module backgrounds).
- No new items beyond what exists today.
- No changes to the icon-map / app-icon font.
- No changes to `theme_change.sh` mechanics (kill+respawn) — only the palette files it switches between.

## Visual identity

- Bar shape: edge-to-edge, flat, full-width. Same dimensions as today (`height=32`, `corner_radius=0`, `margin=0`, no border, no shadow).
- Workspace indicator: glowing dot prefix + uppercase label, accent on active, dim grey on inactive occupied, hidden when empty.
- Right side: colored module text with `│` separator items between logical groups.
- No background pills on any item.

## Palette

### Catppuccin Mocha — `themes/dark.sh`

| Variable | Hex | Used by |
| --- | --- | --- |
| `BAR_COLOR` | `#1e1e2e` (base) | bar background |
| `TEXT_COLOR` / `WHITE` | `#cdd6f4` (text) | clock, default text |
| `DIM` | `#6c7086` (overlay0) | inactive workspaces |
| `SEPARATOR_COLOR` | `#45475a` (surface1) | `│` separators |
| `WORKSPACE_ACTIVE_COLOR` | `#a6e3a1` (green) | active workspace |
| `WORKSPACE_INACTIVE_COLOR` | `#6c7086` | inactive workspaces |
| `FRONT_APP_COLOR` | `#cba6f7` (mauve) | front_app icon + label |
| `GREEN` | `#a6e3a1` | RAM, battery > 50% |
| `CYAN` | `#89dceb` (sky) | CPU, network |
| `AMBER` | `#f9e2af` (yellow) | disk |
| `PURPLE` | `#cba6f7` | (legacy, kept for compatibility) |
| `MAGENTA` | `#f5c2e7` (pink) | (legacy) |
| `RED_SOFT` | `#f38ba8` (red) | battery ≤ 10% |
| `ICON` / `ICON_DIM` | `#a6e3a1` / `#80a6e3a1` | pulse, decorative |
| `ITEM_BG_COLOR` | `0x00000000` | transparent (unchanged) |

### Catppuccin Latte — `themes/light.sh`

| Variable | Hex | Notes |
| --- | --- | --- |
| `BAR_COLOR` | `#eff1f5` (base) | |
| `TEXT_COLOR` / `WHITE` | `#4c4f69` (text) | dark on light |
| `DIM` | `#9ca0b0` (overlay0) | |
| `SEPARATOR_COLOR` | `#bcc0cc` (surface1) | |
| `WORKSPACE_ACTIVE_COLOR` | `#40a02b` (green) | |
| `WORKSPACE_INACTIVE_COLOR` | `#6c6f85` (subtext0) | readable on light |
| `FRONT_APP_COLOR` | `#8839ef` (mauve) | |
| `GREEN` | `#40a02b` | |
| `CYAN` | `#04a5e5` (sky) | |
| `AMBER` | `#df8e1d` (yellow) | |
| `PURPLE` | `#8839ef` | |
| `MAGENTA` | `#ea76cb` (pink) | |
| `RED_SOFT` | `#d20f39` (red) | |
| `ICON` / `ICON_DIM` | `#40a02b` / `#8040a02b` | |
| `ITEM_BG_COLOR` | `0x00000000` | |

`colors.sh` remains a copied snapshot of whichever theme is active — `plugins/theme_change.sh` is unchanged.

## Layout

Item order (left → right):

```
[ws.Virtual] [ws.Dev] [ws.Terminal] [ws.Web] [ws.Reading] [ws.Planing] [ws.Chat] [ws.Inbox] [ws.Any]
[front_app]
... flex space ...
[spotify] [sep_r1] [network] [sep_r2] [cpu] [ram] [disk] [sep_r3] [battery] [sep_r4] [clock]
```

Right-side reading right-to-left: clock, battery, [disk/ram/cpu group with disk closest to battery], network, spotify. Four separator items split five logical zones (spotify | net | sys | battery | clock).

Sketchybar adds `right` items rightmost-first, so the `sketchybarrc` `source` / `--add` order must be (top to bottom): `clock`, `sep_r4`, `battery`, `sep_r3`, `cpu.sh` (the existing file adds `disk` → `ram` → `cpu` internally, producing left-to-right `cpu ram disk`), `sep_r2`, `network`, `sep_r1`, `spotify`.

## Workspaces — `items/workspace.sh`, `plugins/workspace.sh`

- `items/workspace.sh` adds an icon `●` (U+25CF) with `icon.font="JetbrainsMono Nerd Font:Bold:8.0"` and `icon.padding_right=6`. Label keeps the existing uppercase short codes (`DEV`, `WEB`, `TERM`, etc.). No numbers.
- `plugins/workspace.sh` sets both `icon.color` and `label.color`:
  - Active: `icon.color=$WORKSPACE_ACTIVE_COLOR`, `label.color=$WORKSPACE_ACTIVE_COLOR`.
  - Inactive occupied: same color for icon and label = `$WORKSPACE_INACTIVE_COLOR`.
  - Empty: `drawing=off` (unchanged).
- Glow on active is achieved by color saturation — sketchybar has no native shadow on labels, so the visual "glow" in the mockup is approximated by the bright Catppuccin green vs the dim overlay0. No animation changes.
- Per-workspace `padding_right=10` for breathing room (today: 2).

## Front app — `items/front_app.sh`, `plugins/front_app.sh`

- Drop the pill background entirely (no `background.color`, no `background.drawing`).
- Set `icon.color=$FRONT_APP_COLOR`, `label.color=$FRONT_APP_COLOR` in both item and plugin (plugin must set color because `front_app_switched` reruns the plugin and would otherwise reset to defaults — already a known gotcha in this repo).
- Keep `icon.font="sketchybar-app-font:Regular:16"` and the existing `icon_map` logic untouched.
- Padding: `padding_left=10`, `label.padding_left=6`, `padding_right=10`.

## Right-side modules

All modules: `background.drawing=off`, no pills, uppercase labels where it makes sense.

### `clock` (`items/clock.sh`)
- `label.color=$TEXT_COLOR`, no icon.
- `label.padding_left=8`, `padding_right=12`.
- Format unchanged.

### `battery` (`items/battery.sh`, `plugins/battery.sh`)
- Icon font already nerd; keep icon glyph mapping.
- Color scheme (level → color):
  - `>50%` → `$GREEN`
  - `11-50%` → `$AMBER`
  - `≤10%` → `$RED_SOFT`
  - charging suffix `⚡` unchanged.
- Plugin sets icon + label color; drop the trailing ` |` from the label (separator items handle this now).

### CPU group (`items/cpu.sh`, `plugins/{cpu,ram,disk}.sh`)
- Item file already defines `disk`, `ram`, `cpu` (in this order, right→left when added with `right` flag, so visual order ends up `C R D`).
- Colors:
  - `cpu` label → `$CYAN`
  - `ram` label → `$GREEN`
  - `disk` label → `$AMBER`
- Plugin scripts drop the inline ` |` trailing characters; separator items provide the dividers.
- Label format keeps `C:N%` / `R:N%` / `D:N` shorthand (Hyprland-minimal favors short labels).
- Compact padding inside the group: `label.padding_left=4`, `label.padding_right=4`.

### `network` (`items/network.sh`, `plugins/network.sh`)
- `label.color=$CYAN` (was purple — moves under the same accent as CPU since both represent throughput-ish data).
- Plugin drops the trailing ` |` and the `⋮--` placeholder gets the `DIM` color.

### `spotify` (`items/spotify.sh`, `plugins/spotify.sh`)
- Re-enable (`drawing=on`).
- `label.color=$FRONT_APP_COLOR` (mauve), icon glyph stays; drop any background.
- `label.padding_right=8`, `padding_right=6`.
- Plugin already exists and is left untouched apart from setting color.

### Separators (right side)

Four `sep_r{1..4}` items, all `right`-aligned, all using the same definition:

```bash
sketchybar --add item sep_r1 right \
  --set sep_r1 \
    icon="│" \
    icon.font="JetbrainsMono Nerd Font:Regular:13.0" \
    icon.color=$SEPARATOR_COLOR \
    label.drawing=off \
    background.drawing=off \
    padding_left=4 \
    padding_right=4
```

Defined inline in `sketchybarrc` between the right-side `source` lines (no plugin script needed — these are static dividers, not the existing animated `separator.sh`/`separator` item which stays unused/removed if user wants).

## Theme switching

- `plugins/theme_change.sh` is unchanged: it picks `themes/dark.sh` or `themes/light.sh` based on `defaults read -g AppleInterfaceStyle`, copies it over `colors.sh`, then kills+respawns sketchybar.
- Both theme files get the full new palette table. After this work, `colors.sh` is effectively a generated file; the source of truth is the two theme files.

## Files to change

| File | Change |
| --- | --- |
| `themes/dark.sh` | Replace palette with Catppuccin Mocha values + new `DIM` and `SEPARATOR_COLOR` vars |
| `themes/light.sh` | Replace palette with Catppuccin Latte values + new vars |
| `colors.sh` | Copy of `themes/dark.sh` (matches current default appearance) |
| `sketchybarrc` | Add `sep_r1..sep_r4` definitions inline; re-add `source "$ITEM_DIR/spotify.sh"`; ensure right-side `source` order produces the documented item order |
| `items/workspace.sh` | Add `●` icon + bold 8pt font, set `padding_right=10`, keep `drawing=off` initial state |
| `plugins/workspace.sh` | Set both `icon.color` and `label.color` on active/inactive branches |
| `items/front_app.sh` | Remove pill background props if any; keep icon font, mauve color, padding tweaks |
| `plugins/front_app.sh` | Set `icon.color` and `label.color` to `$FRONT_APP_COLOR` after sourcing `colors.sh` |
| `items/clock.sh` | Recolor label to `$TEXT_COLOR`, padding tweaks |
| `items/battery.sh` | Drop trailing ` \|` from label format (handled by separator) |
| `plugins/battery.sh` | New 3-tier color scheme (green/amber/red), drop ` \|` suffix |
| `items/cpu.sh` | Recolor disk→amber, ram→green, cpu→cyan, compact padding |
| `plugins/cpu.sh`, `plugins/ram.sh`, `plugins/disk.sh` | Drop ` \|` suffixes in labels |
| `items/network.sh` | Recolor to `$CYAN`, padding tweaks |
| `plugins/network.sh` | Drop ` \|` suffix; placeholder `⋮--` colored `$DIM` |
| `items/spotify.sh` | Set `drawing=on`, color mauve, padding tweaks |
| `plugins/spotify.sh` | Set `label.color=$FRONT_APP_COLOR` after sourcing `colors.sh` |

## Out of scope (will not change)

- `plugins/theme_change.sh` (kill+respawn mechanics, file copy logic)
- `plugins/icon_map_fn.sh` (app icon lookup)
- `items/pulse.sh` and its plugin (currently disabled in `sketchybarrc`, left as-is)
- `items/separator.sh` / `plugins/separator.sh` (the animated braille separator; not used in this layout and can be left in tree)
- `restart.sh`, `reference.md`, `LICENSE`

## Acceptance criteria

1. After running `sketchybar --reload` (or the kill+respawn from `theme_change.sh`):
   - Bar matches the final mockup colors and structure in both dark and light system appearance.
   - Switching macOS dark↔light flips the bar palette without manual intervention.
   - All 9 Aerospace workspaces show `● LABEL` with active in accent green, inactive occupied in dim, empty hidden.
   - Right side reads (left → right) `[spotify] │ [net] │ [cpu ram disk] │ [battery] │ [clock]`.
   - Front app shows `<icon> <name>` in mauve, no pill.
2. No item shows a background pill.
3. No item shows a trailing ` |` inside its label.
