# Sketchybar: bash → Lua migration

**Date:** 2026-08-04
**Status:** Approved, ready for planning

## Goal

Replace the current bash sketchybar config with the Lua (SbarLua) config from
[flameberry/Dotfiles](https://github.com/flameberry/Dotfiles), keeping the existing
retro-phosphor color palette.

The result is flameberry's *layout, architecture, and item set* with this machine's *colors*.
Nothing is ported forward from the bash config except the palette — items the bash bar had and
flameberry doesn't are dropped, not reimplemented.

## Background

### Current config

`suckless/mac_os/sketchybar/`, symlinked to `~/.config/sketchybar` by `bootstrap/mac.sh:379`.

- Bash, ~58 files, felixkratz/linkarzu lineage
- Full-width opaque bar (`height=32`, `margin=-2`)
- Retro-phosphor green palette sourced through `colors.sh`
- Left: Aerospace workspace indicators, front_app
- Right: calendar, brew, dnd, wifi, battery, volume, mic, network, cpu, custom_text, notification
- One C helper (`helper/helper.c`, CPU sampling)

### Target config

flameberry's `sketchybar/` directory.

- Lua via SbarLua, ~2300 lines across 20 files
- Floating bar (`y_offset=8`, `corner_radius=8`, `shadow`, `margin=128`)
- Notch-aware center layout, with items grouped into `bracket` pills
- Six-theme table with a one-line `active_theme` switch
- Items: apple, spaces (Aerospace or OmniWM backend), media, weather, calendar,
  and battery/volume/wifi/bluetooth/cpu widgets
- Two C helpers: `menus` (Apple-logo menu bar) and `network_load`

### Environment

Already present, so the Lua path adds no new install steps:

| Dependency | Status |
| --- | --- |
| sketchybar | v2.23.0 |
| SbarLua | installed at `~/.local/share/sketchybar_lua` |
| lua | 5.5.0 |
| aerospace | 0.20.3-Beta |
| Hardware | Mac15,7 (16" MacBook Pro — has a notch) |

`nowplaying-cli` and `SwitchAudioSource` are both on PATH, so media and volume-source-switching
work as-is.

**Font:** upstream's `helpers/default_font.lua` names *Satoshi Variable*, which is installed
(family `Satoshi Variable`, styles Light/Regular/Medium/Bold). The file is used verbatim.
Upstream's style map contains a `Black` entry with no matching face in the variable family, but
no item reads it — only `Bold` and `Semibold` are ever looked up.

## Design

### 1. Location and rollback

Replace the contents of `suckless/mac_os/sketchybar/` in place. The `~/.config/sketchybar`
symlink and the `bootstrap/mac.sh` line are unchanged.

Rollback is git — the working tree is clean at the start, so the migration is one revertible
commit. No parallel `sketchybar-new/` directory, and the pre-existing stale `sketchybar-old/`
is left alone (out of scope).

Resulting layout:

```
suckless/mac_os/sketchybar/
  sketchybarrc            init.lua       bar.lua
  default.lua             settings.lua   colors.lua
  icons.lua               utils.lua
  items/                  apple, spaces, spaces_aerospace, media, weather, calendar
  items/widgets/          battery, volume, wifi, bluetooth, cpu
  helpers/                app_icons.lua, default_font.lua, init.lua, menus/
  assets/                 diamondRed.png and friends
```

Two pieces of upstream are dropped: `items/spaces_omniwm.lua` (Aerospace is the only window
manager here) and `helpers/event_providers/network_load/` (no network item consumes it, and
leaving it in means the helper makefile compiles C nothing calls).

### 2. Theme

Keep flameberry's theme-table mechanism, trimmed from six themes to two: `phosphor` (active)
and `catppuccin`. The other four (`rose_pine`, `rose_pine_moon`, `neon`, `aurora`, `gojo`) are
dropped rather than carried as dead config.

`phosphor` is the current `colors.sh` palette translated into flameberry's key names:

| Lua key | Hex | Source |
| --- | --- | --- |
| `base`, `black` | `#000000` | `linkarzu_color10` |
| `surface` | `#061006` | `linkarzu_color17` |
| `overlay` | `#0b180b` | `linkarzu_color07` |
| `muted` | `#245224` | `linkarzu_color15` |
| `subtle`, `grey` | `#4e6f4e` | `linkarzu_color09` |
| `text`, `white` | `#d8ffd8` | `linkarzu_color14` |
| `accent` | `#00e65c` | `linkarzu_color04` (current workspace-active color) |
| `green` | `#00e65c` | `linkarzu_color04` |
| `red` | `#c96d00` | `linkarzu_color11` |
| `yellow` | `#d98a00` | `linkarzu_color12` |
| `orange` | `#ffc94a` | `linkarzu_color01` |
| `magenta`, `iris` | `#66ff99` | `linkarzu_color03` |
| `gold` | `#ffe07a` | `linkarzu_color08` |
| `bar.bg` | `#000000` | opaque |
| `bg1` (bracket fill) | `#0b180b` | `linkarzu_color07` |
| `bg2` (inactive space pill) | `#183818` | `linkarzu_color13` |
| `bg3` (center pill) | `#102210` | `linkarzu_color25` |

**Everything follows the palette.** Upstream has three places that bypass it, all corrected:
`items/apple.lua` used `assets/diamondRed.png` — a red raster image sketchybar cannot recolor,
replaced with the SF Symbols apple glyph in `colors.accent`; and `items/media.lua` had two
hardcoded `0xffffffff` literals, routed through `colors.white`. The only remaining literal is
`bar.lua`'s black bar background, which matches the phosphor base.

**Semantic remap, deliberate:** the bash `colors.sh` assigns `GREEN=#ff9d00` (an orange) and
similar scrambled pairings. flameberry's widgets use these names semantically — a full battery
asks for `colors.green`. Carrying the scramble over would render a full battery orange, so the
Lua `phosphor` theme maps each name to a hue that matches it. The palette is unchanged; only
which swatch answers to which name.

### 3. Bar shape

Adopt the floating bar, but with `margin = 12` instead of flameberry's `128`. Their deep inset
surrenders roughly a quarter of the screen width; 12 reads as floating without the cost. Single
constant in `bar.lua`, tunable after first look.

`y_offset = 8`, `corner_radius = 8`, `shadow = true`, `height = 32`, opaque black background.

Notch spacer width `230`, sized for the 16" panel. Single constant in `items/init.lua`.

### 4. Layout

| Region | Contents |
| --- | --- |
| Left bracket | apple diamond → Aerospace workspace pills |
| Center, left of notch | media |
| Center, right of notch | weather → time → date |
| Right bracket | wifi → bluetooth → volume → battery |

Workspace pills follow flameberry's behavior: unfocused and empty → not drawn; unfocused with
windows → a small empty dark oval; focused → accent-filled pill showing the workspace name plus
its app icons. App icons render only in the focused pill.

Workspace names on this machine are words (`Any Chat Dev Inbox Planing Reading Terminal Virtual
Web`), and `display_label` prints the id verbatim, so the focused pill will be wider than
flameberry's numeric workspaces produce. Only one pill is focused at a time, so this is
accepted as-is.

**Pill order:** Aerospace reports workspaces alphabetically, which puts `Any` and `Chat` ahead of
`Dev` and `Terminal`. The pills are ordered explicitly instead — **Dev, Terminal, Web, Chat,
Reading, Planing, Any, Inbox, Virtual** — via a `display_order` array on the spaces backend, so
`spaces.lua` stays window-manager agnostic. Workspaces absent from that array sort alphabetically
after the listed ones, so adding one in `aerospace.toml` never makes it invisible.

### 5. Item disposition

The bar ships exactly flameberry's item set. Nothing is hand-ported.

**Kept (from flameberry):** apple, spaces, media, weather, calendar, battery, volume, wifi,
bluetooth.

`cpu` is left commented out in `items/init.lua` and in the right bracket, as upstream has it.
Enabling it later is a two-line uncomment.

**Dropped (bash config only):**

| Item | Reason |
| --- | --- |
| `mic`, `brew`, `dnd`, `network` | Not in flameberry's set; not worth hand-porting |
| `front_app` | The focused workspace pill already renders the app icons for that workspace |
| `custom_text` | Already dead — watches `~/github/dotfiles-latest/youtube-banner.txt`, a path from linkarzu's repo. Verified missing on this machine |
| `notification` | Already dead — watches `~/.dotfiles/dotfiles-latest/custom-notification.txt`, likewise missing. Verified |
| `spotify`, `github`, `svim`, `mikrotik`, `timer`, `workspace`, `yabai` | Already commented out of the current `sketchybarrc`, or superseded (`workspace` → `spaces.lua`, `yabai` → Aerospace) |

**Gained:** `weather` (wttr.in), `bluetooth`, `media` (nowplaying-cli, replacing the disabled
`spotify` item), and the `menus` helper on the Apple logo.

The net trade is losing mic level, brew count, DND state, and network throughput from the bar,
in exchange for a much smaller config with no bespoke code to maintain.

### 6. Module boundaries

flameberry's structure is already well-factored and is kept as-is:

- `colors.lua` — palette only, returns a flat table. No item knows a hex value.
- `settings.lua` — paddings, fonts, icon set. No colors.
- `items/spaces.lua` — rendering and event coalescing, window-manager agnostic.
- `items/spaces_aerospace.lua` — the backend contract: `events`, `list_workspaces_cmd()`,
  `fetch_state_cmd()`, `click_cmd(id)`, `display_label(id)`.
- `items/widgets/*.lua` — one file per widget, each self-contained.
- `items/init.lua` — composition root: what is added, in what order, and the brackets.

Since no items are being written, the only file materially diverging from upstream is
`colors.lua` (trimmed theme table plus the new `phosphor` entry), with one-constant edits in
`bar.lua` (`margin`) and `items/init.lua` (notch width).

### 7. Verification

No test suite applies to a status bar. Verification is manual and must be performed before the
work is called done:

1. `sketchybar --reload`, then confirm the log is free of Lua errors.
2. Switch through every Aerospace workspace; confirm pills draw, focus follows, and app icons
   appear for occupied workspaces.
3. Play and pause media; confirm the center item updates and hides when nothing plays.
4. Mute and change volume; confirm the widget and the source-switch right-click work.
5. Unplug power; confirm the battery widget changes state and color.
6. Confirm wifi, bluetooth, weather, time, and date all populate.
7. Click the Apple diamond; confirm the `menus` helper opens the macOS menu bar.
8. Screenshot the bar and share it.

## Out of scope

- Removing the stale `suckless/mac_os/sketchybar-old/` directory.
- Changing `bootstrap/mac.sh` or the `~/.config/sketchybar` symlink.
- Adopting anything else from flameberry's repo (aerospace, ghostty, nvim, tmux, borders).
- Adding a light theme. The bar stays dark-only, as it is today.
