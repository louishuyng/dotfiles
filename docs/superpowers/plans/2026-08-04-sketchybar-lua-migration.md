# Sketchybar Lua Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bash sketchybar config at `suckless/mac_os/sketchybar/` with flameberry/Dotfiles' Lua (SbarLua) config, restyled to the existing retro-phosphor palette.

**Architecture:** Vendor upstream's Lua tree in place, then make four localized edits — prune the two upstream pieces this machine doesn't use, point the font at an installed family, add a `phosphor` theme to the theme table, and adjust two geometry constants. No items are written by hand.

**Tech Stack:** Lua 5.5, SbarLua (`~/.local/share/sketchybar_lua`), sketchybar v2.23.0, Aerospace 0.20.3-Beta, clang via CommandLineTools (for the `menus` helper).

**Spec:** `docs/superpowers/specs/2026-08-04-sketchybar-lua-migration-design.md`

## Global Constraints

- Config lives at `suckless/mac_os/sketchybar/`, symlinked to `~/.config/sketchybar`. Do **not** modify the symlink or `bootstrap/mac.sh:379`.
- Do **not** touch `suckless/mac_os/sketchybar-old/` — explicitly out of scope.
- No items are ported from the bash config. If a task tempts you to write `mic`, `brew`, `dnd`, `network`, `front_app`, `custom_text`, or `notification`, stop — they were deliberately dropped.
- `cpu` stays commented out in `items/init.lua`, as upstream has it.
- Dark-only. Do not add a light theme or appearance detection.
- Every task ends with a working bar. Verification for each is `sketchybar --reload` followed by an item-count query and an error-log delta — there is no test suite for a status bar.
- The sketchybar error log is `/opt/homebrew/var/log/sketchybar/sketchybar.err.log`. It is already ~147MB from the bash config, so always diff by byte offset rather than reading the whole file.

## File Structure

| Path | Responsibility |
| --- | --- |
| `sketchybarrc` | Entry point. Requires `helpers` then `init`. |
| `init.lua` | Boots SbarLua, wraps config in `begin_config`/`end_config`, starts the event loop. |
| `bar.lua` | Bar geometry only. **Modified:** `margin`. |
| `default.lua` | Default item properties (fonts, paddings, popup styling). |
| `settings.lua` | Paddings, icon set, font handle. |
| `colors.lua` | Palette. **Rewritten theme table:** `phosphor` (active) + `catppuccin`. |
| `icons.lua` | SF Symbols / NerdFont glyph tables. |
| `utils.lua` | `menubar_section` bracket helper. |
| `items/init.lua` | Composition root — item order and brackets. **Modified:** notch width. |
| `items/apple.lua` | Apple diamond + `menus` click handler. |
| `items/spaces.lua` | Workspace pill rendering, WM-agnostic. |
| `items/spaces_aerospace.lua` | Aerospace backend. |
| `items/media.lua`, `weather.lua`, `calendar.lua` | Center items. |
| `items/widgets/*.lua` | battery, volume, wifi, bluetooth, cpu. |
| `helpers/init.lua` | Sets `package.cpath`, runs the helper makefile. |
| `helpers/default_font.lua` | Font family + style map. **Modified:** family and style map. |
| `helpers/app_icons.lua` | App-name → sketchybar-app-font glyph map. |
| `helpers/makefile` | **Modified:** builds `menus` only. |
| `helpers/menus/` | C helper for the Apple-logo menu bar. |
| `assets/` | PNGs, including `diamondRed.png` used by the Apple item. |

**Deleted:** every `*.sh` in the current config (`sketchybarrc`, `colors.sh`, `icons.sh`, `items/`, `plugins/`, `helper/`).
**Not vendored:** `items/spaces_omniwm.lua`, `helpers/event_providers/`, `sketchybar_backup_best/`.

---

### Task 1: Vendor the Lua config in place

Replaces the bash tree wholesale. At the end of this task the bar runs upstream's config verbatim minus the two pruned pieces — wrong colors and a fallback font, but functional. Later tasks fix appearance.

**Files:**
- Delete: all of `suckless/mac_os/sketchybar/` (58 files)
- Create: the Lua tree listed in File Structure above
- Modify: `suckless/mac_os/sketchybar/helpers/makefile`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: a loadable Lua config. Later tasks edit `helpers/default_font.lua`, `colors.lua`, `bar.lua`, and `items/init.lua`, all of which must exist after this task.

- [ ] **Step 1: Record the baseline so the verification in Step 9 has something to compare against**

```bash
cd /Users/louishuyng/.dotfiles
sketchybar --query bar | python3 -c "import sys,json; print('items:', len(json.load(sys.stdin)['items']))"
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log > /tmp/sb-log-offset
cat /tmp/sb-log-offset
```

Expected: `items: 19` and a byte offset around 147000000. Record both.

- [ ] **Step 2: Clone upstream**

```bash
git clone --depth 1 https://github.com/flameberry/Dotfiles.git /tmp/flameberry-dotfiles
ls /tmp/flameberry-dotfiles/sketchybar
```

Expected: `assets bar.lua colors.lua default.lua helpers icons.lua init.lua items settings.lua sketchybarrc utils.lua`

- [ ] **Step 3: Remove the bash config**

The working tree must be clean before this. `git rm` rather than `rm` so the deletion is staged and reviewable.

```bash
cd /Users/louishuyng/.dotfiles
git status --porcelain suckless/mac_os/sketchybar   # must print nothing
git rm -r -q suckless/mac_os/sketchybar
ls suckless/mac_os/sketchybar 2>&1
```

Expected: the `ls` reports no such file or directory. `sketchybar-old/` must still exist alongside it.

- [ ] **Step 4: Copy the Lua tree in**

```bash
cd /Users/louishuyng/.dotfiles
cp -R /tmp/flameberry-dotfiles/sketchybar suckless/mac_os/sketchybar
ls suckless/mac_os/sketchybar
```

Expected: the upstream file list from Step 2.

- [ ] **Step 5: Prune the two pieces this machine does not use**

`spaces_omniwm.lua` is the OmniWM backend (Aerospace is the only WM here). `event_providers/` contains only `network_load`, which no item consumes now that the network item is dropped — leaving it means the helper makefile compiles C nothing calls.

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar
rm items/spaces_omniwm.lua
rm -r helpers/event_providers
```

- [ ] **Step 6: Point the helper makefile at `menus` only**

Without this, `make` fails on the now-missing `event_providers` directory every time sketchybar starts.

Replace the entire contents of `suckless/mac_os/sketchybar/helpers/makefile` with:

```makefile
all:
	(cd menus && $(MAKE)) >/dev/null
```

- [ ] **Step 7: Build the helper**

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar/helpers && make
ls menus/bin/menus
```

Expected: `menus/bin/menus` exists. If the build errors, stop and report — `xcode-select -p` should be `/Library/Developer/CommandLineTools`.

- [ ] **Step 8: Reload sketchybar**

```bash
sketchybar --reload
sleep 3
```

- [ ] **Step 9: Verify it loaded**

```bash
sketchybar --query bar | python3 -c "import sys,json; d=json.load(sys.stdin); print('items:', len(d['items'])); print('margin:', d['margin'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -40
```

Expected: item count is non-zero and different from 19 (upstream adds roughly 15–25 items depending on media state). `margin: 128`, confirming `bar.lua` took effect. The log delta must contain no `lua:` tracebacks, no `attempt to index a nil value`, and no `module ... not found`.

If the item count is 0, the Lua config threw during load — read the log delta, fix, and re-run from Step 8.

The bar will look wrong at this point: crimson `gojo` colors, a fallback font, and a deep 128px inset. That is expected and handled by Tasks 2–4.

- [ ] **Step 10: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add -A suckless/mac_os/sketchybar
git commit -m "feat(sketchybar): replace bash config with flameberry Lua config

Vendors flameberry/Dotfiles' SbarLua config in place. Drops the OmniWM
spaces backend and the network_load event provider, neither of which
this machine uses, and narrows the helper makefile to match.

Colors, font, and bar geometry are adjusted in follow-up commits."
```

---

### Task 2: Point the font at an installed family

Upstream's `default_font.lua` names **Satoshi Variable**, which is not installed on this machine — every label silently falls back to a system default. JetBrainsMono Nerd Font is installed (48 faces) and is what the bash bar used.

**Files:**
- Modify: `suckless/mac_os/sketchybar/helpers/default_font.lua`

**Interfaces:**
- Consumes: the vendored tree from Task 1.
- Produces: `settings.font.text`, `settings.font.numbers`, and `settings.font.style_map[k]` for keys `Regular`, `Semibold`, `Bold`, `Heavy`, `Black`. Every item file reads these; all five keys must remain present or items referencing a missing key will index nil.

- [ ] **Step 1: Confirm which faces actually exist**

```bash
system_profiler SPFontsDataType | grep -A2 -i "jetbrainsmono nerd font" | grep -i "style" | sed 's/.*: //' | sort -u
```

Expected to include: `Regular`, `Medium`, `SemiBold`, `Bold`, `ExtraBold`. Note there is **no** `Black` face — that is why the map below sends both `Heavy` and `Black` to `ExtraBold`.

- [ ] **Step 2: Replace the file**

Write `suckless/mac_os/sketchybar/helpers/default_font.lua`:

```lua
-- JetBrainsMono Nerd Font, not upstream's Satoshi Variable, which is not
-- installed here. Style names must match real faces or sketchybar falls
-- back silently; JetBrainsMono ships no Black face, hence Heavy/Black →
-- ExtraBold.
return {
	text = "JetBrainsMono Nerd Font",
	numbers = "JetBrainsMono Nerd Font",

	style_map = {
		["Regular"] = "Regular",
		["Semibold"] = "SemiBold",
		["Bold"] = "Bold",
		["Heavy"] = "ExtraBold",
		["Black"] = "ExtraBold",
	},
}
```

- [ ] **Step 3: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log > /tmp/sb-log-offset
sketchybar --reload
sleep 3
sketchybar --query center.date | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['label']['font'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: the font string names `JetBrainsMono Nerd Font` with a real style. Log delta clean.

Then look at the bar: text should be visibly monospaced. If it still looks like a proportional system font, the family name is wrong — recheck Step 1's output for the exact spelling.

- [ ] **Step 4: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/helpers/default_font.lua
git commit -m "fix(sketchybar): use JetBrainsMono Nerd Font instead of uninstalled Satoshi"
```

---

### Task 3: Add the phosphor theme

Translates the bash `colors.sh` retro-phosphor palette into upstream's theme-table format, and trims the table from six themes to two.

**Files:**
- Modify: `suckless/mac_os/sketchybar/colors.lua`

**Interfaces:**
- Consumes: the vendored tree from Task 1.
- Produces: a flat table read by every item as `require("colors")`. It must expose, at minimum: `base surface overlay muted subtle text love gold rose pine foam iris highlight_low highlight_med highlight_high black white red green blue yellow orange magenta grey transparent accent bar.bg bar.border popup.bg popup.border bg1 bg2 bg3` and the function `with_alpha(color, alpha)`. Dropping any key breaks whichever item reads it.

- [ ] **Step 1: Rewrite the theme table**

Keep the file's existing shape — `local themes = { ... }`, then `active_theme`, then the `with_alpha` closure and `return theme`. Replace only the table contents and the active selection.

Delete the `rose_pine`, `rose_pine_moon`, `neon`, `aurora`, and `gojo` entries. Keep `catppuccin` exactly as upstream has it. Add:

```lua
	-- Retro-phosphor green, carried over from the previous bash config's
	-- colors.sh. Semantic names are mapped to matching hues rather than
	-- copied verbatim: colors.sh assigned GREEN to an orange, which would
	-- render a full battery orange here.
	phosphor = {
		base = 0xff000000,
		surface = 0xff061006,
		overlay = 0xff0b180b,
		muted = 0xff245224,
		subtle = 0xff4e6f4e,
		text = 0xffd8ffd8,
		love = 0xffc96d00,
		gold = 0xffffe07a,
		rose = 0xffffc94a,
		pine = 0xff00cc4f,
		foam = 0xff98ff98,
		iris = 0xff66ff99,
		highlight_low = 0xff061006,
		highlight_med = 0xff102210,
		highlight_high = 0xff183818,

		black = 0xff000000,
		white = 0xffd8ffd8,
		red = 0xffc96d00,
		green = 0xff00e65c,
		blue = 0xff66ff99,
		yellow = 0xffd98a00,
		orange = 0xffffc94a,
		magenta = 0xff66ff99,
		grey = 0xff4e6f4e,
		transparent = 0x00000000,
		accent = 0xff00e65c,

		bar = { bg = 0xff000000, border = 0xff0b180b },
		popup = { bg = 0xff000000, border = 0xff00e65c },
		bg1 = 0xff0b180b,
		bg2 = 0xff183818,
		bg3 = 0xff102210,
	},
```

- [ ] **Step 2: Set the active theme**

Change the selection line to:

```lua
local active_theme = "phosphor" -- options: "phosphor", "catppuccin"
```

- [ ] **Step 3: Verify the table is complete before reloading**

A missing key surfaces as a nil-index traceback at load, which is slower to diagnose than checking directly:

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar
lua -e '
local c = dofile("colors.lua")
local required = {"base","surface","overlay","muted","subtle","text","love","gold","rose","pine","foam","iris","highlight_low","highlight_med","highlight_high","black","white","red","green","blue","yellow","orange","magenta","grey","transparent","accent","bg1","bg2","bg3"}
local missing = {}
for _, k in ipairs(required) do if c[k] == nil then missing[#missing+1] = k end end
assert(c.bar and c.bar.bg and c.bar.border, "bar.bg / bar.border missing")
assert(c.popup and c.popup.bg and c.popup.border, "popup.bg / popup.border missing")
assert(type(c.with_alpha) == "function", "with_alpha missing")
if #missing > 0 then error("missing keys: " .. table.concat(missing, ", ")) end
print("colors.lua OK")
'
```

Expected: `colors.lua OK`. Anything else — add the reported keys and re-run.

- [ ] **Step 4: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log > /tmp/sb-log-offset
sketchybar --reload
sleep 3
sketchybar --query bar | python3 -c "import sys,json; print('bar color:', json.load(sys.stdin)['color'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: `bar color: 0xff000000`. Log delta clean.

Then look at the bar: the focused workspace pill should be phosphor green (`#00e65c`) with black text on it. No crimson anywhere.

- [ ] **Step 5: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/colors.lua
git commit -m "feat(sketchybar): add phosphor theme, trim theme table to two

Carries the retro-phosphor palette over from the bash config's colors.sh.
Semantic color names are remapped to matching hues — colors.sh had GREEN
bound to an orange, which the Lua widgets would render on a full battery."
```

---

### Task 4: Adjust bar geometry

Upstream floats the bar with a 128px inset on each side, which surrenders roughly a quarter of the screen width. The notch spacer also needs sizing for this 16" panel.

**Files:**
- Modify: `suckless/mac_os/sketchybar/bar.lua`
- Modify: `suckless/mac_os/sketchybar/items/init.lua`

**Interfaces:**
- Consumes: the vendored tree from Task 1.
- Produces: no symbols. Two constants only.

- [ ] **Step 1: Narrow the bar inset**

In `bar.lua`, change the `margin` line from `margin = 128,` to:

```lua
	margin = 12,
```

Leave `y_offset`, `corner_radius`, `shadow`, and `height` at their upstream values — those are what make it read as floating.

- [ ] **Step 2: Size the notch spacer**

In `items/init.lua`, the `center.notch` item has `width = 200` with a comment suggesting 220–250 for a 16" MBP. This machine is a Mac15,7 (16"). Change it to:

```lua
	width = 230,
```

- [ ] **Step 3: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log > /tmp/sb-log-offset
sketchybar --reload
sleep 3
sketchybar --query bar | python3 -c "import sys,json; d=json.load(sys.stdin); print('margin:', d['margin'], 'corner_radius:', d['corner_radius'], 'y_offset:', d['y_offset'])"
sketchybar --query center.notch | python3 -c "import sys,json; print('notch width:', json.load(sys.stdin)['geometry']['width'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: `margin: 12 corner_radius: 8 y_offset: 8` and `notch width: 230`. Log delta clean.

Then look at the bar: it should float near-full-width with rounded corners, and no item should be clipped by the notch. If items bleed under the notch, raise the width to 250; if there is an obvious gap, lower it toward 200.

- [ ] **Step 4: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/bar.lua suckless/mac_os/sketchybar/items/init.lua
git commit -m "style(sketchybar): narrow bar inset to 12px, size notch for 16in panel"
```

---

### Task 5: Full verification sweep

Spec section 7. Nothing here is automatable — it is the manual pass that decides whether the migration is actually done.

**Files:**
- Modify: `/Users/louishuyng/.claude/projects/-Users-louishuyng--dotfiles/memory/project_sketchybar.md`

**Interfaces:**
- Consumes: everything from Tasks 1–4.
- Produces: a screenshot and a corrected memory file.

- [ ] **Step 1: Clean reload from a known state**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log > /tmp/sb-log-offset
sketchybar --reload
sleep 5
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log
```

Expected: no Lua tracebacks in the delta.

- [ ] **Step 2: Walk every workspace**

```bash
for ws in Virtual Dev Terminal Web Reading Planing Chat Inbox Any; do aerospace workspace "$ws"; sleep 1; done
aerospace workspace Dev
```

Confirm by eye: the focused pill is phosphor green showing the workspace name plus app icons; occupied-but-unfocused workspaces show small dark ovals; empty ones are not drawn at all. Clicking a pill switches to it.

- [ ] **Step 3: Media**

Start playback in any player, confirm the item left of the notch shows the track, then pause and confirm it clears.

```bash
nowplaying-cli get title artist
sketchybar --query center.media | python3 -c "import sys,json; d=json.load(sys.stdin); print('drawing:', d['geometry']['drawing'], 'label:', d['label']['value'])"
```

The item is `center.media` — `center.media.title` exists only inside the popup, as `popup.center.media.title`.

- [ ] **Step 4: Volume**

Change volume with the keyboard, confirm the widget tracks it. Right-click it and confirm the audio-source switcher appears (`SwitchAudioSource` is installed).

- [ ] **Step 5: Battery**

Unplug power, wait ~5s, confirm the icon and color change. Plug back in and confirm it returns.

- [ ] **Step 6: Remaining items**

Confirm wifi shows the SSID, bluetooth reflects connected devices, and weather, time, and date all populate. Weather hits `wttr.in`, so allow ~10s on first load.

```bash
for i in widgets.wifi widgets.bluetooth widgets.battery widgets.volume center.weather center.time center.date; do
  echo -n "$i: "; sketchybar --query $i | python3 -c "import sys,json; print(json.load(sys.stdin)['label']['value'])"
done
```

Expected: no empty values other than ones that are legitimately blank (bluetooth with nothing connected).

- [ ] **Step 7: Apple menu helper**

Click the diamond at the far left. Expected: the macOS menu bar opens via `helpers/menus/bin/menus -s 0`.

- [ ] **Step 8: Screenshot and share**

```bash
screencapture -x /tmp/sketchybar-after.png
```

Show the result to the user. Adjust `margin` in `bar.lua` or the notch width in `items/init.lua` if the proportions look off, then re-verify and amend the Task 4 commit.

- [ ] **Step 9: Correct the stale memory file**

`project_sketchybar.md` currently describes a Tokyo Night bash config with guidance about editing `plugins/*.sh` — all of it wrong after this migration. Rewrite the body to describe the Lua config: SbarLua at `suckless/mac_os/sketchybar/`, `phosphor` active in `colors.lua`'s theme table, JetBrainsMono Nerd Font, floating bar at `margin = 12`, notch spacer 230, flameberry's item set with `cpu` commented out, and the fact that mic/brew/dnd/network/front_app were deliberately dropped rather than ported.

- [ ] **Step 10: Commit any final tweaks**

```bash
cd /Users/louishuyng/.dotfiles
git status --porcelain suckless/mac_os/sketchybar
```

If clean, the migration is done. If Step 8 produced geometry tweaks, commit them:

```bash
git add suckless/mac_os/sketchybar
git commit -m "style(sketchybar): tune bar geometry after visual check"
```

---

## Rollback

Every task is a separate commit and the pre-migration state is one revert away:

```bash
cd /Users/louishuyng/.dotfiles
git log --oneline -6                    # find the commit before Task 1
git revert --no-commit <task1>..HEAD
sketchybar --reload
```
