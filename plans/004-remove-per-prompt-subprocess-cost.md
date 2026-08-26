# 004 — Stop forking a subprocess on every fish prompt to detect dark mode

- **Status:** TODO
- **Category:** performance
- **Severity:** high
- **Effort:** S
- **Fix risk:** low
- **Written against commit:** `9c7d0ed5`
- **Depends on:** none

## Problem

This is a personal dotfiles repository on macOS. The fish shell config is `terminals/fish/`,
symlinked to `~/.config/fish/`. The user profiles their own shell startup and cares about
milliseconds — `terminals/fish/config.fish:85-91` contains a comment accounting for "5.7ms of a
122ms startup".

`terminals/fish/config.fish` wraps starship's prompt function to auto-detect the macOS light/dark
appearance. The wrapper shells out to `/usr/libexec/PlistBuddy` **on every single prompt render** —
after every command, every `cd`, every bare Enter — to read one value that changes maybe twice a
day. The `$_cached_appearance` comparison guards the *theme re-source*, not the *process spawn*, so
the fork happens unconditionally.

Measured at commit `9c7d0ed5` on this machine, 10 invocations:

```
$ /usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist
11.7 ms per invocation
```

For comparison, `defaults read -g AppleInterfaceStyle` is **13.1 ms** — no better. But fish's
`builtin path mtime` is a stat with no fork:

```
$ builtin path mtime ~/Library/Preferences/.GlobalPreferences.plist
0.07 ms per call
```

So the expensive call can be gated behind a cheap one: stat the plist, and only run PlistBuddy when
the file has actually changed. That is roughly a **165× reduction** on the common path, and it is
the same caching shape the repo already uses in `terminals/fish/functions/__init_cached.fish`
(cache keyed on a binary's mtime).

**A second, larger per-prompt cost exists but is deliberately NOT fixed by this plan** — see
"Part 2" below. Read it before you start.

## Evidence

`terminals/fish/config.fish:16-38` at commit `9c7d0ed5`. Line 23 is the per-prompt fork:

```fish
# --print-full-init: plain `starship init fish` only emits a stub that shells out to
# this again, so caching the stub would still pay for the second call.
__init_cached starship init fish --print-full-init

# Wrap starship's fish_prompt to auto-detect macOS appearance on each prompt
functions -c fish_prompt __starship_fish_prompt
function fish_prompt
    set -l _appearance (/usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
    if test -z "$_appearance"
        set _appearance Light
    end
    if test "$_appearance" != "$_cached_appearance"
        set -g _cached_appearance $_appearance
        if test "$_appearance" = Dark
            source ~/.dotfiles/terminals/fish/themes/catppuccin-mocha.fish
            set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/config.toml
        else
            source ~/.dotfiles/terminals/fish/themes/catppuccin-latte.fish
            set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/catppuccin-latte.toml
        end
    end
    __starship_fish_prompt
end
```

The exemplar to imitate — `terminals/fish/functions/__init_cached.fish:19-24` — already uses
`builtin path mtime` with a graceful fallback when it is unavailable:

```fish
    # path mtime needs fish 3.5+; fall back to generating live rather than guessing.
    set -l mtime (builtin path mtime $exe 2>/dev/null)
    if test -z "$mtime"
        $exe $sub | source
        return
    end
```

Confirmed working on this machine (fish 4.8.0):
```
$ fish -c 'echo (builtin path mtime ~/Library/Preferences/.GlobalPreferences.plist)'
1786289920
```

## Why this approach

Gate the expensive read behind a cheap stat of the file the value lives in. When the plist's mtime
is unchanged, skip PlistBuddy entirely and reuse the cached appearance.

The failure mode if the assumption is wrong is mild and self-correcting: macOS's preference daemon
(`cfprefsd`) coalesces writes, so the plist's mtime *could* lag the actual appearance toggle by a
few seconds. The consequence is that the shell theme switches a few seconds late, and it fixes
itself on the next prompt after the write lands. That is an acceptable trade for removing 11.7 ms
from every prompt — but it must be verified, so step 4 is a manual check.

Rejected alternatives:

- *`defaults read -g AppleInterfaceStyle`* — measured **slower** (13.1 ms). It is a different fork,
  not a cheaper one.
- *Cache in a universal variable so new shells skip the first read.* `set -U` writes to disk and
  fish 4.x moved theme variables out of universal scope deliberately (see the comment at
  `terminals/fish/config.fish:4-9` documenting a past fight with exactly this). Not worth the risk
  for one read per shell.
- *An external listener on `AppleInterfaceThemeChangedNotification` writing a marker file.* This is
  genuinely the best long-term design — it would also unify the three separate appearance detectors
  in this repo (fish, `k7s.fish`, and nvim's `auto-dark-mode.nvim` 1000 ms poll). It is out of scope
  here because it adds a background component with its own failure mode (if the listener dies, the
  theme freezes with no obvious cause). Recorded as a direction item, not a fix.

## Repo conventions to follow

- One function per file in `terminals/fish/functions/`, filename matching the function name.
- `set -gx` for global exports; the repo deliberately avoids `set -U` for anything theme-related
  (see `terminals/fish/config.fish:4-9`).
- Format with `fish_indent`.
- The repo writes substantial "why" comments explaining non-obvious performance decisions — see
  `terminals/fish/functions/__init_cached.fish:1-11` and `terminals/fish/conf.d/mise.fish:1-9`.
  Match that density: explain *why* the mtime gate exists and note the cfprefsd caveat, so the next
  reader does not "simplify" it away.
- Guard optional things rather than assuming, as `__init_cached.fish:19-24` does.

## Files in scope

- `terminals/fish/config.fish` — the `fish_prompt` wrapper only (lines 20-38).

## Out of scope — do not touch

- **`terminals/fish/config.fish:1` (`__init_cached mise activate fish`)** — this is the larger
  per-prompt cost. See Part 2. Do **not** change it.
- `terminals/fish/functions/__init_cached.fish` — read it as a pattern, do not modify it.
- `terminals/fish/functions/fish_prompt.fish` — a stale copy of fish's default prompt that is dead
  code (starship defines `fish_prompt` before it could ever autoload). Tracked separately; leave it.
- `terminals/fish/conf.d/fish_frozen_theme.fish` — sets pager colors that the catppuccin theme files
  do not override. Tracked separately; leave it.
- `terminals/fish/themes/catppuccin-mocha.fish` and `catppuccin-latte.fish` — do not edit.
- `terminals/fish/functions/k7s.fish` — has its own `defaults read` appearance check. Tracked
  separately as part of the "one source of truth" direction item; leave it.
- Anything under `nvim/`.

## Steps

### 1. Record the baseline

```bash
for i in 1 2 3 4 5; do /usr/bin/time -p fish -c 'exit' 2>&1 | awk '/real/{printf "%s ms\n", $2*1000}'; done
```
Record the numbers. Expected at commit `9c7d0ed5`: around 100–110 ms each.

Confirm the current per-prompt cost:
```bash
S=$(python3 -c 'import time;print(time.time())')
for i in $(seq 1 10); do /usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist >/dev/null 2>&1; done
E=$(python3 -c 'import time;print(time.time())')
python3 -c "print(f'{($E-$S)*100:.1f} ms per invocation')"
```
Expected: roughly 8–15 ms. If it is under 1 ms, something differs from the plan's assumptions —
report before continuing.

Also record the current appearance so you can tell whether the theme still follows it:
```bash
/usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null || echo "(unset = Light)"
```

### 2. Add the mtime gate to the prompt wrapper

Edit the `fish_prompt` function in `terminals/fish/config.fish` (lines 22-38) so that:

- It first reads the plist's mtime with `builtin path mtime <plist> 2>/dev/null` into a local.
- If that mtime is **non-empty and equal** to a cached mtime (a `set -g` variable, e.g.
  `$_cached_appearance_mtime`), it skips PlistBuddy entirely and goes straight to
  `__starship_fish_prompt`.
- Otherwise it stores the new mtime, runs PlistBuddy exactly as today, and keeps the existing
  `$_cached_appearance` comparison and theme-sourcing logic **unchanged**.
- If `builtin path mtime` returns empty (older fish, or the file is missing), it falls through to
  running PlistBuddy every time — the current behavior. Do not let a missing mtime silently pin the
  appearance forever. Copy the fallback shape from `__init_cached.fish:19-24`.

Preserve exactly:
- the `2>/dev/null` on the PlistBuddy call,
- the `test -z "$_appearance"` → `Light` default,
- both `source` lines and both `STARSHIP_CONFIG` assignments,
- the final `__starship_fish_prompt` call, which must run on **every** path.

Add a comment explaining why the gate exists (cite the 11.7 ms vs 0.07 ms measurement) and noting
the cfprefsd write-coalescing caveat.

Verify the file parses:
```bash
fish --no-execute terminals/fish/config.fish ; echo "exit=$?"
```
Expected: no output, `exit=0`.

### 3. Verify the prompt still works and is faster

Start an interactive shell and confirm the prompt renders. `HERDR_ENV=1` is required to bypass the
`exec herdr` guard at `terminals/fish/config.fish:92-94`, which would otherwise replace the shell:

```bash
HERDR_ENV=1 fish -i -c 'echo prompt-ok; exit' 2>&1 | tail -3
```
Expected: `prompt-ok`, no errors.

Confirm the theme variables are set correctly for the current appearance:
```bash
HERDR_ENV=1 fish -i -c 'echo "STARSHIP_CONFIG=$STARSHIP_CONFIG"; echo "cached=$_cached_appearance"; exit' 2>&1 | tail -3
```
Expected: `cached` matches the appearance you recorded in step 1, and `STARSHIP_CONFIG` points at
`config.toml` for Dark or `catppuccin-latte.toml` for Light.

Measure the improvement — render many prompts in one shell and compare:
```bash
S=$(python3 -c 'import time;print(time.time())')
HERDR_ENV=1 fish -i -c 'for i in (seq 50); fish_prompt >/dev/null; end; exit' 2>/dev/null
E=$(python3 -c 'import time;print(time.time())')
python3 -c "print(f'{($E-$S)*1000/50:.2f} ms per prompt render')"
```
Run this **before and after** your change if you can (stash, measure, unstash) — otherwise just
record the after number and compare against the ~11.7 ms baseline from step 1. Expected: a large
drop, since the PlistBuddy fork now runs at most once.

### 4. Manually verify the theme still follows a real appearance toggle

**This step needs the user, or explicit permission to change a system setting.** It is the one
assumption the plan cannot verify from code: whether macOS updates the plist's mtime promptly.

Ask the user to toggle appearance (System Settings → Appearance, or Control Centre), then in an
already-open fish shell press Enter a couple of times and confirm the prompt colors follow within a
few seconds.

If you have been told you may do it yourself, this toggles and restores it:
```bash
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
# ... check a shell prompt ...
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
```

**If the theme does not follow within ~10 seconds: STOP and report back.** The mtime gate is
unsound on this machine and the change should be reverted rather than worked around. Do not add a
timer, a poll, or a "check every N prompts" hack to compensate — that is a redesign and needs a
decision from the user.

### 5. Format

```bash
fish_indent -w terminals/fish/config.fish
git diff terminals/fish/config.fish
```
Expected: the diff shows only your prompt-wrapper change. If `fish_indent` reformats unrelated
regions, that is pre-existing drift — mention it in your report.

## Part 2 — measure, do NOT change

There is a second per-prompt fork, and it is **larger** than the one you just fixed.
`terminals/fish/config.fish:1` runs `__init_cached mise activate fish`. The script that produces
registers an event handler:

```
$ fish -c 'functions --handlers | grep fish_prompt'
fish_prompt __fish_on_interactive
fish_prompt __mise_env_eval
```

`__mise_env_eval` runs `mise hook-env` before every prompt. `__init_cached` caches the *text* of the
activation script — its own comment at `terminals/fish/functions/__init_cached.fish:4-6` says so —
so the per-prompt subprocess is untouched by that optimisation. Measured at 33 ms standalone on this
machine; measured at 13.6 ms from inside a warm mise-activated fish. Either way it is the single
largest per-prompt cost in the config.

**Do not change it.** The obvious fix — `mise activate fish --shims` — removes the prompt hook but
also stops mise from setting environment variables, which changes behavior for every tool the user
manages with mise. That is the user's call, not the executor's.

Your task for Part 2 is only to **measure and report**:

```bash
S=$(python3 -c 'import time;print(time.time())')
for i in $(seq 20); do mise hook-env -s fish >/dev/null 2>&1; done
E=$(python3 -c 'import time;print(time.time())')
python3 -c "print(f'{($E-$S)*1000/20:.1f} ms per mise hook-env')"
```

Include the number in your report so the user can decide whether a follow-up is worth it.

## Test plan

There is no test suite in this repository and one is not wanted. The verification is:
- step 2's `fish --no-execute` parse check,
- step 3's functional checks (prompt renders, theme variables correct, timing improved),
- step 4's manual appearance-toggle check, which is the one that can falsify the approach.

## Done criteria

All must hold, run from the repo root (`/Users/louishuyng/.dotfiles`):

```bash
# 1. Syntax is valid
fish --no-execute terminals/fish/config.fish ; test $? -eq 0 && echo ok

# 2. The mtime gate is present
grep -n "path mtime" terminals/fish/config.fish   # should match

# 3. PlistBuddy is still the source of truth (not replaced by something else)
grep -n "PlistBuddy" terminals/fish/config.fish   # should still match exactly once

# 4. An interactive shell starts and renders a prompt
HERDR_ENV=1 fish -i -c 'echo prompt-ok; exit' 2>&1 | tail -1

# 5. Theme state is correct for the current appearance
HERDR_ENV=1 fish -i -c 'echo "$_cached_appearance $STARSHIP_CONFIG"; exit' 2>&1 | tail -1

# 6. Per-prompt cost dropped materially versus the ~11.7 ms baseline
# (the 50-render measurement from step 3)

# 7. Step 4's manual toggle check passed

# 8. Scope
git status --porcelain
```

For #8, the only file your work may add to the modified list is `terminals/fish/config.fish`. The
repo has pre-existing uncommitted changes to other files — those are the user's own work. Leave
them untouched and do not commit anything.

## Escape hatches

STOP and report back instead of improvising if:

- Step 4's manual toggle check fails — the theme does not follow within ~10 seconds. Revert your
  change; do not compensate with a timer or a periodic re-check.
- `builtin path mtime` returns empty for the plist on this machine (step 1 showed it working, so
  this would mean something changed).
- The measured PlistBuddy cost in step 1 is under 1 ms — the premise of the plan does not hold here.
- Making this work appears to require touching `terminals/fish/config.fish:1` (the mise line) or any
  other file.
- `fish_indent` is not installed (report it; do not hand-format).

## Drift check

This plan was written against commit `9c7d0ed5`. Before starting:

```bash
git log --oneline 9c7d0ed5..HEAD -- terminals/fish/config.fish
```

`terminals/fish/config.fish` is one of the highest-churn files in this repo (9 commits in the last
six months). If the command lists commits, the excerpt above is likely stale — read the current file
first and report if the prompt wrapper has materially changed.

## Maintenance note

The rule this establishes: **anything running inside `fish_prompt` runs on every keystroke-to-prompt
cycle and must not fork a process.** If a prompt component needs data from a subprocess, gate it on
something cheap — an mtime, a variable, a file that something else maintains. Reviewers should treat
any new command substitution inside `fish_prompt` as a defect until proven otherwise.

Two related items deliberately left alone, both recorded for future work:

1. **The mise prompt hook** (Part 2) is the larger remaining cost and needs a user decision about
   `--shims` versus keeping mise's env-var management.
2. **Three independent appearance detectors** exist in this repo: this one, `defaults read` in
   `terminals/fish/functions/k7s.fish`, and `auto-dark-mode.nvim` polling every 1000 ms in the
   Neovim config. They have already diverged in *which* theme they select — fish is hardwired to
   catppuccin while the Neovim state file currently holds `{"light":"github","dark":"catppuccin"}`,
   so the two halves of one terminal window can disagree. A single listener writing a marker file
   would fix all three at once. That is a design change, not a bug fix.
