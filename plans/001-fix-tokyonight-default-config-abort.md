# 001 — Fix the default dark theme that aborts the entire Neovim config

- **Status:** TODO
- **Category:** correctness
- **Severity:** critical
- **Effort:** S
- **Fix risk:** low
- **Written against commit:** `9c7d0ed5`
- **Depends on:** none

## Problem

This repository is a personal dotfiles repo. Its Neovim configuration lives in `nvim/` and is
loaded from `nvim/init.lua`, which requires five modules in order: `config`, `mappings`, `cmds`,
`ui`, `options`.

The theme module picks a colorscheme by name and looks it up in a table of "adapters". Its default
dark theme is `'tokyonight'`, but no adapter with that name exists — not on disk, and not in the
lookup table. When the lookup misses, the code calls `error()`, which is an uncaught Lua error
inside `require('config')`. Because `require('config')` is the *first* of the five requires in
`nvim/init.lua`, the error aborts the whole file: `mappings`, `cmds`, `ui`, and `options` never
run. The user gets a Neovim with no keymaps, no LSP, and no options set.

This is masked on the current machine only by an accident: a state file at
`~/.local/state/nvim/theme.json` contains `{"light":"github","dark":"catppuccin"}`, and the module
reads that file at load time and overwrites the bad default before it is ever used. Any machine
without that file hits the bug — a fresh clone, a new machine, a wiped state directory, or a
hand-edited/corrupt `theme.json`.

**Reproduced at commit `9c7d0ed5`** by pointing the state directory at an empty folder:

```
$ XDG_STATE_HOME=/tmp/emptystate nvim --headless +qa
Error in /Users/louishuyng/.config/nvim/init.lua:
E5113: Lua chunk: .../lua/config/theme/init.lua:53: config.theme: unknown theme "tokyonight"
stack traceback:
        [C]: in function 'error'
        .../lua/config/theme/init.lua:45: in function 'get_adapter'
        .../lua/config/theme/init.lua:53: in function 'ensure_setup'
        .../lua/config/theme/init.lua:108: in function 'apply'
        .../lua/config/theme/init.lua:152: in main chunk
        [C]: in function 'require'
        .../lua/config/init.lua:5: in main chunk
        [C]: in function 'require'
        .../init.lua:23: in main chunk
```

**Important trap:** that command still **exits 0**. Neovim reports the error on stderr but does not
set a non-zero exit status. Any verification you write must check that *stderr is empty*, not that
the exit code is zero.

## Evidence

`nvim/lua/config/theme/init.lua:64-67` — the defaults. `dark` names a theme with no adapter:

```lua
M.config = {
  dark = 'tokyonight',
  light = 'catppuccin',
}
```

`nvim/lua/config/theme/init.lua:41-50` — the lookup, which hard-errors on an unknown name:

```lua
local function get_adapter(name)
  if not adapters[name] then
    local loader = adapter_loaders[name]
    if not loader then
      error(('config.theme: unknown theme %q'):format(name), 2)
    end
    adapters[name] = loader()
  end
  return adapters[name]
end
```

`nvim/lua/config/theme/init.lua:152` — `apply` is called unconditionally at module load, so the
error fires during `require`:

```lua
apply(active_variant)
```

`nvim/lua/config/theme/init.lua:83-88` — note that `load_state` **already validates** names read
from the state file against `adapter_loaders`, and silently ignores unknown ones. The hardcoded
default gets no such check. This asymmetry is the bug:

```lua
  for _, variant in ipairs({ 'dark', 'light' }) do
    local name = data[variant]
    if type(name) == 'string' and adapter_loaders[name] then
      M.config[variant] = name
    end
  end
```

The six adapters that actually exist, from `ls nvim/lua/config/theme/adapters/`:

```
catppuccin.lua  cendre.lua  github.lua  gruvbox_material.lua  melange.lua  solarized_osaka.lua
```

`nvim/lua/config/pack.lua` does not install `folke/tokyonight.nvim` either, so adding an adapter
would also require adding the plugin. That is **out of scope** here — see below.

## Why this approach

Two independent changes, both small:

1. **Change the default to a theme that exists** (`catppuccin`). It is already the `light` default,
   it has an adapter, and it is what the current state file selects for dark — so this matches what
   the machine actually runs today and changes nothing observable.
2. **Make `get_adapter` degrade instead of `error()`.** Fixing only the default leaves the same
   landmine for the next typo, and for a `theme.json` hand-edited to a name that was later removed.
   A config should not be destroyed by one bad theme name.

Rejected: adding a `tokyonight` adapter. That means adding a plugin to `pack.lua` and writing a
~100-line adapter to match the five existing ones — a feature, not a bug fix, and it would leave
the `error()` landmine in place regardless.

## Repo conventions to follow

- **Formatter:** StyLua, config at `nvim/.stylua.toml` — 120 columns, 2-space indent, Unix line
  endings, `AutoPreferSingle` quotes (so use `'single'` quotes).
- **Error handling:** the config's documented pattern is early-return on failure and `vim.notify`
  for user-visible warnings. `nvim/lua/config/theme/init.lua:80` is the exemplar to copy, in this
  very file:
  ```lua
  vim.notify('config.theme: ignoring malformed ' .. state_path, vim.log.levels.WARN)
  ```
- Keep the existing `config.theme: ` message prefix on any notification you add.

## Files in scope

- `nvim/lua/config/theme/init.lua` — the only file to change.

## Out of scope — do not touch

- `nvim/lua/config/pack.lua` — do **not** add `tokyonight.nvim` or any other plugin.
- `nvim/lua/config/theme/adapters/` — do **not** create a new adapter file. Note `cendre.lua` has
  uncommitted local modifications; leave it entirely alone.
- `~/.local/state/nvim/theme.json` — do not delete or edit the user's state file.
- Any other `error()` call elsewhere in the config. Only the theme lookup is in scope.
- Reformatting the rest of the file, renaming anything, or "while I'm here" cleanups.

## Steps

### 1. Point the dark default at an adapter that exists

In `nvim/lua/config/theme/init.lua:65`, change `dark = 'tokyonight',` to `dark = 'catppuccin',`.

Verify the literal is gone:
```bash
grep -n "tokyonight" nvim/lua/config/theme/init.lua
```
Expected: no output (exit code 1 from grep is correct here).

### 2. Make the adapter lookup degrade instead of aborting

In `nvim/lua/config/theme/init.lua`, replace the `error(...)` call inside `get_adapter` (line 45)
so that an unknown theme name warns and falls back to `catppuccin` instead of throwing.

Requirements for your implementation:
- It must `vim.notify(...)` at `vim.log.levels.WARN` with a message starting `config.theme: `.
- The message must include the unknown name so the user can find their typo.
- It must fall back to `'catppuccin'` and continue.
- It must **not** recurse infinitely if the fallback itself is somehow missing — if
  `adapter_loaders['catppuccin']` is also nil, `error()` is the correct behavior at that point,
  because there is nothing left to fall back to.

Verify the file still parses as Lua:
```bash
luajit -bl nvim/lua/config/theme/init.lua /dev/null 2>&1 || nvim --headless -c "luafile nvim/lua/config/theme/init.lua" -c qa 2>&1 | head -5
```
Expected: no syntax errors. (The first command may not exist on this machine; the fallback runs the
file through Neovim's own parser. Either passing is sufficient.)

### 3. Verify the original failure is gone

This is the step that proves the fix. Run Neovim with an empty state directory — the exact
condition that reproduced the bug:

```bash
rm -rf /tmp/plan001state && mkdir -p /tmp/plan001state
XDG_STATE_HOME=/tmp/plan001state nvim --headless +qa 2>&1
```

Expected output: **either completely empty, or exactly this one line and nothing else:**
```
vim.tbl_flatten is deprecated. Run ":checkhealth vim.deprecated" for more information
```

That deprecation line is **pre-existing noise emitted by a third-party plugin**, present at commit
`9c7d0ed5` before your change. It is not your problem and not in scope — do not try to fix it, and
do not treat it as a failure.

**If you see any line containing `E5113`, `unknown theme`, or `stack traceback`: STOP and report
back.** The fix did not work and something in the plan's assumptions is wrong.

### 4. Verify normal startup still works

```bash
nvim --headless +qa 2>&1
```
Expected: same as step 3 — empty, or only the `vim.tbl_flatten` line.

### 5. Verify the fallback path actually fires

Confirm step 2 works by forcing an unknown name through the state file:

```bash
rm -rf /tmp/plan001state2 && mkdir -p /tmp/plan001state2/nvim
echo '{"dark":"catppuccin","light":"catppuccin"}' > /tmp/plan001state2/nvim/theme.json
XDG_STATE_HOME=/tmp/plan001state2 nvim --headless +qa 2>&1
```
Expected: clean (empty or the `tbl_flatten` line only).

Note: you cannot easily force the *unknown-name* path through `theme.json`, because `load_state`
already filters unknown names (see Evidence). To exercise the fallback, temporarily set
`M.config.dark` to a junk value in a scratch copy — **not** in the repo file — or simply reason
through the branch. Do not leave any junk value committed.

### 6. Format

```bash
stylua nvim/lua/config/theme/init.lua
git diff --stat nvim/lua/config/theme/init.lua
```
Expected: the file is listed. If StyLua reformats lines unrelated to your change, that is
pre-existing drift — leave it, and mention it in your report.

## Test plan

There is no test suite in this repository and one is not wanted. The verification is the commands
in steps 3–5, which reproduce the original failure condition and prove it no longer occurs.

## Done criteria

All must hold, run from the repo root (`/Users/louishuyng/.dotfiles`):

```bash
# 1. No reference to the nonexistent theme remains
grep -rn "tokyonight" nvim/lua/config/theme/init.lua   # no output

# 2. Fresh-state startup is clean
rm -rf /tmp/plan001state && mkdir -p /tmp/plan001state
XDG_STATE_HOME=/tmp/plan001state nvim --headless +qa 2>&1   # empty, or only the tbl_flatten line

# 3. Normal startup is clean
nvim --headless +qa 2>&1                                     # empty, or only the tbl_flatten line

# 4. Formatting is clean
stylua --check nvim/lua/config/theme/init.lua                # exits 0

# 5. Scope is respected
git status --porcelain
```

For #5, the only file your work may add to the modified list is
`nvim/lua/config/theme/init.lua`. The repo already has pre-existing uncommitted changes to other
files (including `nvim/lua/config/theme/adapters/cendre.lua`) — those are the user's own work.
Leave them untouched and do not commit anything.

## Escape hatches

STOP and report back instead of improvising if:

- Step 3 still shows `E5113` or `unknown theme` after your change.
- `stylua` is not installed on this machine (report it; do not hand-format the file).
- Making the fallback work appears to require changing any file other than
  `nvim/lua/config/theme/init.lua`.
- The excerpts in the Evidence section do not match what you find in the file — the code has moved
  since this plan was written; report that instead of guessing.

## Drift check

This plan was written against commit `9c7d0ed5`. Before starting:

```bash
git log --oneline 9c7d0ed5..HEAD -- nvim/lua/config/theme/
```

If that lists commits, the line numbers and excerpts above may be stale. Read the current file
first; if it has materially changed, report that rather than executing.

## Maintenance note

After this change, an unknown theme name degrades to a warning instead of destroying the config.
Two things for reviewers to watch: (1) the `dark`/`light` defaults in `M.config` must always name
an adapter that exists in `nvim/lua/config/theme/adapters/` — there is still no automated check
tying those together; (2) if someone later adds a `tokyonight` adapter plus the plugin, the default
can be moved back, but the `get_adapter` fallback should stay regardless.

The broader lesson this bug illustrates — that `require('config')` is unprotected, so *any* error
in any of the ~20 modules it loads takes down the whole config — is real but deliberately not
addressed here. Wrapping those requires in `pcall` is a separate design decision.
