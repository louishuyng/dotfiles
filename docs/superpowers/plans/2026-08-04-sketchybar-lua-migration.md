# Sketchybar Lua Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bash sketchybar config at `suckless/mac_os/sketchybar/` with flameberry/Dotfiles' Lua (SbarLua) config, restyled to the existing retro-phosphor palette.

**Architecture:** Vendor upstream's Lua tree in place, then make five localized edits — prune the two upstream pieces this machine doesn't use, add a `phosphor` theme to the theme table, adjust two geometry constants, impose an explicit workspace display order, and hue-rotate the Apple diamond asset onto the palette. No items are written by hand.

**Tech Stack:** Lua 5.5, SbarLua (`~/.local/share/sketchybar_lua`), sketchybar v2.23.0, Aerospace 0.20.3-Beta, clang via CommandLineTools (for the `menus` helper).

**Spec:** `docs/superpowers/specs/2026-08-04-sketchybar-lua-migration-design.md`

## Global Constraints

- Config lives at `suckless/mac_os/sketchybar/`, symlinked to `~/.config/sketchybar`. Do **not** modify the symlink or `bootstrap/mac.sh:379`.
- Do **not** touch `suckless/mac_os/sketchybar-old/` — explicitly out of scope.
- No items are ported from the bash config. If a task tempts you to write `mic`, `brew`, `dnd`, `network`, `front_app`, `custom_text`, or `notification`, stop — they were deliberately dropped.
- `cpu` stays commented out in `items/init.lua`, as upstream has it.
- Dark-only. Do not add a light theme or appearance detection.
- Every task ends with a working bar. Verification for each is `sketchybar --reload` followed by an item-count query and an error-log delta — there is no test suite for a status bar.
- The sketchybar error log is `/opt/homebrew/var/log/sketchybar/sketchybar.err.log`. It is already ~147MB from the bash config, so always diff by byte offset rather than reading the whole file. Pipe `wc -c` through `tr -d " "` — macOS pads the count with a leading space, which makes `tail -c +N` fail with "illegal offset".

## Prerequisite resolved during Task 1

The installed `~/.local/share/sketchybar_lua/sketchybar.so` was built 2025-08-03 against Lua 5.4. Homebrew's `lua` was later upgraded to 5.5.0, and since Lua C modules resolve symbols against the host interpreter, `require("sketchybar")` segfaulted (exit 139, uncatchable by `pcall`) — the config loaded zero items with no Lua traceback in the log.

Fixed by rebuilding SbarLua, whose upstream now vendors and statically links lua-5.5.0:

```bash
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua && make install
```

The prior `.so` is backed up at `/tmp/sketchybar.so.bak-a6efebf8`. **`bootstrap/mac.sh` installs sketchybar but never installs SbarLua** — a fresh machine would hit this same wall. Adding it there is deliberately out of scope for this plan; see Follow-ups.

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
| `items/apple.lua` | Apple diamond + `menus` click handler. **Modified:** repointed at the green asset. |
| `items/spaces.lua` | Workspace pill rendering, WM-agnostic. **Modified:** applies the backend's display order. |
| `items/spaces_aerospace.lua` | Aerospace backend. **Modified:** declares `display_order`. |
| `items/media.lua`, `weather.lua`, `calendar.lua` | Center items. `media.lua` **modified:** two hardcoded whites routed through the palette. |
| `items/widgets/*.lua` | battery, volume, wifi, bluetooth, cpu. |
| `helpers/init.lua` | Sets `package.cpath`, runs the helper makefile. |
| `helpers/default_font.lua` | Font family + style map. Used verbatim — Satoshi Variable is installed. |
| `helpers/app_icons.lua` | App-name → sketchybar-app-font glyph map. |
| `helpers/makefile` | **Modified:** builds `menus` only. |
| `helpers/menus/` | C helper for the Apple-logo menu bar. |
| `assets/` | PNGs. **Added:** `diamondGreen.png`, a hue-rotated `diamondRed.png` for the Apple item. |

**Deleted:** every `*.sh` in the current config (`sketchybarrc`, `colors.sh`, `icons.sh`, `items/`, `plugins/`, `helper/`).
**Not vendored:** `items/spaces_omniwm.lua`, `helpers/event_providers/`, `sketchybar_backup_best/`.

---

### Task 1: Vendor the Lua config in place

Replaces the bash tree wholesale. At the end of this task the bar runs upstream's config verbatim minus the two pruned pieces — wrong colors and geometry, but functional. Later tasks fix appearance.

**Files:**
- Delete: all of `suckless/mac_os/sketchybar/` (58 files)
- Create: the Lua tree listed in File Structure above
- Modify: `suckless/mac_os/sketchybar/helpers/makefile`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: a loadable Lua config. Later tasks edit `colors.lua`, `bar.lua`, and `items/init.lua`, all of which must exist after this task.

- [ ] **Step 1: Record the baseline so the verification in Step 9 has something to compare against**

```bash
cd /Users/louishuyng/.dotfiles
sketchybar --query bar | python3 -c "import sys,json; print('items:', len(json.load(sys.stdin)['items']))"
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
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

The bar will look wrong at this point: crimson `gojo` colors and a deep 128px inset. That is expected and handled by Tasks 2–3. Text should already render in Satoshi Variable, since that font is installed and upstream's `default_font.lua` is used as-is.

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

### Task 2: Add the phosphor theme

Translates the bash `colors.sh` retro-phosphor palette into upstream's theme-table format, and trims the table from six themes to two.

**Files:**
- Modify: `suckless/mac_os/sketchybar/colors.lua`
- Modify: `suckless/mac_os/sketchybar/items/media.lua`

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

- [ ] **Step 4: Route media.lua's hardcoded whites through the palette**

Two spots bypass the palette with a literal white. Both must read from `colors` so a theme switch actually reaches them.

`items/media.lua:102` — inside the popup title item, change:

```lua
		color = 0xffffffff,
```

to:

```lua
		color = colors.white,
```

`items/media.lua:339` — change:

```lua
	local color = faded and colors.with_alpha(colors.white, faded) or 0xffffffff
```

to:

```lua
	local color = faded and colors.with_alpha(colors.white, faded) or colors.white
```

Confirm `local colors = require("colors")` is already at the top of `media.lua` (it is — line 339 already uses `colors.with_alpha`).

- [ ] **Step 5: Verify no non-palette color literals remain outside colors.lua**

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar
grep -rn "0x[0-9a-fA-F]\{8\}" --include="*.lua" . | grep -v "^\./colors.lua\|^colors.lua"
```

The filter matches both with and without a `./` prefix on purpose: BSD grep (and ugrep, which is what `grep` resolves to on this machine) does not prefix recursive-search filenames the way GNU grep does, so an anchored `^./colors.lua` alone silently matches nothing and the whole palette floods the output.

Expected: exactly one line — `bar.lua:6`, which uses `0xff000000`/`0x00000000` for the bar background. That one is left alone: it is geometry-adjacent, black matches the phosphor base, and `bar.lua` is Task 3's file. Any other hit means a literal was missed.

Do **not** touch `items/apple.lua`. Its `assets/diamondRed.png` reference is expected here and is handled by Task 5, which recolors the asset rather than replacing the icon.

- [ ] **Step 6: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
sketchybar --reload
sleep 4
sketchybar --query bar | python3 -c "import sys,json; print('bar color:', json.load(sys.stdin)['color'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: `bar color: 0xff000000`. Log delta clean.

Then look at the bar: the focused workspace pill is phosphor green (`#00e65c`) with black text on it, and no crimson remains anywhere except the Apple diamond, which Task 5 handles.

- [ ] **Step 7: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/colors.lua suckless/mac_os/sketchybar/items/media.lua
git commit -m "feat(sketchybar): add phosphor theme, route stray literals through it

Carries the retro-phosphor palette over from the bash config's colors.sh.
Semantic color names are remapped to matching hues — colors.sh had GREEN
bound to an orange, which the Lua widgets would render on a full battery.

Also routes media.lua's two hardcoded white literals through the palette."
```

---

### Task 3: Adjust bar geometry

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
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
sketchybar --reload
sleep 3
sketchybar --query bar | python3 -c "import sys,json; d=json.load(sys.stdin); print('margin:', d['margin'], 'corner_radius:', d['corner_radius'], 'y_offset:', d['y_offset'])"
sketchybar --query center.notch | python3 -c "import sys,json; print('notch width:', json.load(sys.stdin)['width'])"
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

### Task 4: Order the workspace pills

Aerospace's `list-workspaces --all` returns alphabetical order (`Any Chat Dev Inbox Planing Reading Terminal Virtual Web`), which buries the most-used workspaces behind `Any` and `Chat`. Impose an explicit display order instead.

**Requested order:** Dev, Terminal, Web, Chat, Reading, Planing, Any, Inbox, Virtual.

**Files:**
- Modify: `suckless/mac_os/sketchybar/items/spaces_aerospace.lua`
- Modify: `suckless/mac_os/sketchybar/items/spaces.lua`

**Interfaces:**
- Consumes: the vendored tree from Task 1.
- Produces: a new optional key on the spaces backend contract, `M.display_order` — an array of workspace-id strings. `spaces.lua` must treat it as optional (a backend without it keeps the order the WM reported), because the contract is shared with any future backend.

- [ ] **Step 1: Declare the order in the Aerospace backend**

The order belongs to the backend, not the renderer — `spaces.lua` stays window-manager agnostic. Append to `items/spaces_aerospace.lua`, before the final `return M`:

```lua
-- Pill display order, most-used first. Aerospace's list-workspaces returns
-- alphabetical order, which buries the workspaces used most. Workspaces absent
-- from this list still get a pill — they sort alphabetically after the listed
-- ones — so adding a workspace in aerospace.toml never makes it invisible here.
M.display_order = {
	"Dev",
	"Terminal",
	"Web",
	"Chat",
	"Reading",
	"Planing",
	"Any",
	"Inbox",
	"Virtual",
}
```

- [ ] **Step 2: Apply the order in the renderer**

In `items/spaces.lua`, find this line:

```lua
local workspaces = exec_to_table(backend.list_workspaces_cmd())
```

Replace it with the helper plus the reordered call. Items are added to sketchybar in loop order and rendered left-to-right, so sorting the list is all that is needed:

```lua
-- Sort by the backend's declared display order. Unlisted workspaces sort
-- alphabetically after the listed ones. table.sort is not stable in Lua, hence
-- the explicit alphabetical tiebreaker rather than relying on input order.
local function apply_display_order(list, order)
	if not order then
		return list
	end
	local rank = {}
	for i, name in ipairs(order) do
		rank[name] = i
	end
	local ordered = {}
	for _, name in ipairs(list) do
		ordered[#ordered + 1] = name
	end
	table.sort(ordered, function(a, b)
		local ra, rb = rank[a], rank[b]
		if ra and rb then
			return ra < rb
		elseif ra then
			return true
		elseif rb then
			return false
		end
		return a < b
	end)
	return ordered
end

local workspaces = apply_display_order(exec_to_table(backend.list_workspaces_cmd()), backend.display_order)
```

- [ ] **Step 3: Confirm the "only show when occupied" behavior — do not change it**

The requirement that pills appear only for workspaces with applications is already upstream's behavior, in `build_space_set`:

```lua
local should_draw = selected or has_icons
```

Empty, unfocused workspaces are not drawn. **Leave this line alone.** The focused workspace stays visible even when empty, deliberately — hiding it would leave no indication of which workspace you are on. If that turns out to be unwanted, the one-line change is `local should_draw = has_icons`, but it is not part of this task.

Verify by reading the file that the line is unmodified, and confirm it visually in Step 5.

- [ ] **Step 4: Check the order logic in isolation before reloading**

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar
lua -e '
local order = {"Dev","Terminal","Web","Chat","Reading","Planing","Any","Inbox","Virtual"}
local rank = {}
for i, n in ipairs(order) do rank[n] = i end
local got = {"Any","Chat","Dev","Inbox","Planing","Reading","Terminal","Virtual","Web","Zebra"}
table.sort(got, function(a,b)
  local ra, rb = rank[a], rank[b]
  if ra and rb then return ra < rb elseif ra then return true elseif rb then return false end
  return a < b
end)
print(table.concat(got, " "))
'
```

Expected exactly: `Dev Terminal Web Chat Reading Planing Any Inbox Virtual Zebra`

The unlisted `Zebra` landing last confirms new workspaces still appear rather than vanishing.

- [ ] **Step 5: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
sketchybar --reload
sleep 4
sketchybar --query bar | python3 -c "
import sys,json
d = json.load(sys.stdin)
print(' '.join(i.replace('space.','') for i in d['items'] if i.startswith('space.')))
"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: `Dev Terminal Web Chat Reading Planing Any Inbox Virtual`. Log delta clean.

Then confirm by eye: pills read left-to-right in that order, and only workspaces with windows show one (plus the focused workspace).

- [ ] **Step 6: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/items/spaces.lua suckless/mac_os/sketchybar/items/spaces_aerospace.lua
git commit -m "feat(sketchybar): order workspace pills by use, not alphabetically

Aerospace reports workspaces alphabetically, which buries the most-used
ones. display_order lives on the backend so spaces.lua stays window-manager
agnostic; unlisted workspaces sort alphabetically after the listed ones so a
new workspace never silently disappears."
```

---

### Task 5: Recolor the Apple diamond to phosphor green

The Apple logo is `assets/diamondRed.png`, a red raster asset. sketchybar cannot recolor an image, so it survives the phosphor theme as the one red element on an otherwise green bar.

**The icon stays a diamond** — the user explicitly wants the same icon the upstream config uses, not a substituted glyph. So the asset itself is recolored, preserving its exact shape and two-tone shading, and `apple.lua` is repointed at the new file.

**Files:**
- Create: `suckless/mac_os/sketchybar/assets/diamondGreen.png`
- Modify: `suckless/mac_os/sketchybar/items/apple.lua`

**Interfaces:**
- Consumes: the `phosphor` theme from Task 2 (for the accent hue this matches).
- Produces: nothing other tasks read.

- [ ] **Step 1: Generate the green asset**

A hue rotation is used rather than a flat fill so the original's lighter face and darker right-hand edge are both preserved. The values below were derived by sampling until the face landed on the phosphor accent family; use them exactly.

```bash
cd /Users/louishuyng/.dotfiles/suckless/mac_os/sketchybar/assets
magick diamondRed.png -modulate 80,175,184 diamondGreen.png
magick diamondGreen.png -format "face: %[pixel:p{200,250}]\n" info:
magick diamondGreen.png -format "edge: %[pixel:p{440,300}]\n" info:
```

Expected exactly:

```
face: srgba(0,255,92,1)
edge: srgba(0,202,62,1)
```

`#00FF5C` face against the theme's `#00e65c` accent — same hue family, marginally brighter so it still reads at the ~20px the bar renders it at.

`diamondRed.png` is left in place. It is upstream's asset and costs nothing to keep.

- [ ] **Step 2: Repoint the Apple item**

In `items/apple.lua`, change only the image filename on line 9:

```lua
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/diamondGreen.png",
```

Change nothing else in the file. In particular, leave the commented-out `icon` block commented out — the diamond image is the intended icon.

- [ ] **Step 3: Reload and verify**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
sketchybar --reload
sleep 4
sketchybar --query apple.logo | python3 -c "import sys,json; print('image:', json.load(sys.stdin)['background']['image']['string'])"
tail -c +$(cat /tmp/sb-log-offset) /opt/homebrew/var/log/sketchybar/sketchybar.err.log | head -20
```

Expected: the image path ends in `diamondGreen.png`. Log delta clean.

Then look at the far left of the bar: a green diamond, no red anywhere on the bar. If the diamond renders as a blank gap, the path is wrong — the item resolves it through the `~/.config/sketchybar` symlink, not a repo-relative path.

- [ ] **Step 4: Commit**

```bash
cd /Users/louishuyng/.dotfiles
git add suckless/mac_os/sketchybar/assets/diamondGreen.png suckless/mac_os/sketchybar/items/apple.lua
git commit -m "feat(sketchybar): recolor the Apple diamond to phosphor green

sketchybar cannot recolor an image, so the red diamond survived the
phosphor theme as the only red element on the bar. Hue-rotated from
upstream's own diamondRed.png (magick -modulate 80,175,184) so the shape
and two-tone shading are unchanged and only the hue moves onto the palette."
```

---

### Task 6: Full verification sweep

Spec section 7. Nothing here is automatable — it is the manual pass that decides whether the migration is actually done.

**Files:**
- Modify: `/Users/louishuyng/.claude/projects/-Users-louishuyng--dotfiles/memory/project_sketchybar.md`

**Interfaces:**
- Consumes: everything from Tasks 1–5.
- Produces: a screenshot and a corrected memory file.

- [ ] **Step 1: Clean reload from a known state**

```bash
wc -c < /opt/homebrew/var/log/sketchybar/sketchybar.err.log | tr -d " " > /tmp/sb-log-offset
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

`project_sketchybar.md` currently describes a Tokyo Night bash config with guidance about editing `plugins/*.sh` — all of it wrong after this migration. Rewrite the body to describe the Lua config: SbarLua at `suckless/mac_os/sketchybar/`, `phosphor` active in `colors.lua`'s theme table, Satoshi Variable, floating bar at `margin = 12`, notch spacer 230, flameberry's item set with `cpu` commented out, and the fact that mic/brew/dnd/network/front_app were deliberately dropped rather than ported.

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

## Follow-ups (not this plan)

- `bootstrap/mac.sh` installs sketchybar but not SbarLua, and the config is now useless without it. A fresh machine needs the `git clone … && make install` step added, plus `brew install nowplaying-cli switchaudio-osx` and the Satoshi Variable font.
- `sketchybar.err.log` reached 147MB under the bash config. Worth investigating what was erroring in a loop, and whether log rotation is configured.
- `suckless/mac_os/sketchybar-old/` is still present and now two generations stale.

## Rollback

Every task is a separate commit and the pre-migration state is one revert away:

```bash
cd /Users/louishuyng/.dotfiles
git log --oneline -6                    # find the commit before Task 1
git revert --no-commit <task1>..HEAD
sketchybar --reload
```
