# 005 — Move the startup `git` fork off the critical path and make the treesitter size guard work

- **Status:** DONE (item A fully; item B partially — see "Post-execution correction")
- **Category:** performance / correctness
- **Severity:** medium
- **Effort:** S
- **Fix risk:** low
- **Written against commit:** `9c7d0ed5`
- **Depends on:** none

## Problem

This is a personal dotfiles repository; the Neovim config lives in `nvim/` and is symlinked to
`~/.config/nvim/`. Two defects, grouped because both are small autocmd-ordering mistakes in the
startup path and share one verification setup.

**(A) A blocking `git` subprocess runs at every Neovim startup for a Python-only feature.**
`nvim/lua/cmds/python_autoset_path.lua` calls `git rev-parse --show-toplevel` through `io.popen` at
**module load time** — that is, on every `require('cmds')`, which `nvim/init.lua:29` does
unconditionally. The value is used only to set `PYTHONPATH` when a `.py` buffer is entered.

Measured at commit `9c7d0ed5` with `nvim --headless --startuptime`, this module costs **~19 ms**,
making it the most expensive non-plugin module in the config, out of a 241 ms total. It is paid
whether or not a Python file is ever opened.

Three problems flow from computing it once, at load, from Neovim's launch directory:

1. **Startup cost** — ~19 ms of blocking fork on every launch.
2. **Stderr leak** — `io.popen` does not redirect stderr, so launching Neovim outside a git
   repository prints `fatal: not a git repository (or any of the parent directories): .git` into
   the UI during startup. In that case `capture` returns an empty string and `PYTHONPATH` becomes
   the literal `/src`.
3. **Wrong value** — the path is frozen at launch. Open a Python file from a *different* repository
   in the same session (via Telescope, `:oldfiles`, or after a `cd`) and `PYTHONPATH` still points
   at the first repo's `src`, so any `:terminal` or test runner spawned from Neovim imports the
   wrong modules.

**(B) The 100 KB treesitter guard never fires.**
`nvim/lua/config/cores/treesitter.lua` registers two autocmds: a `FileType` handler that starts
treesitter for every filetype, and a `BufReadPre` handler that stops it for files over 100 KB.

`BufReadPre` fires **before** the file is read, and long before `FileType`. So the `stop` call runs
against a buffer where treesitter was never started (a no-op), and the `FileType` handler then
starts it unconditionally a moment later. Large files get full treesitter parsing and highlighting
— exactly the case the guard was written to prevent.

## Evidence

**(A)** `nvim/lua/cmds/python_autoset_path.lua` — the entire file, at commit `9c7d0ed5`. Line 3 runs
at module load, outside any callback:

```lua
local os_extend = require('utils.os_extend')

local top_level = os_extend.capture('git rev-parse --show-toplevel') .. '/src'

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.py',
  callback = function()
    vim.env.PYTHONPATH = top_level
  end,
})
```

`nvim/lua/utils/os_extend.lua:3-14` — the helper. Note no stderr redirection, and `assert` on
failure:

```lua
function M.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
```

`nvim/lua/cmds/init.lua:2` — the unconditional require that pulls it into startup:

```lua
require 'cmds.python_autoset_path'
```

Measured hotspots from `nvim --headless --startuptime`, total 241 ms:

```
207.902  sourcing .../init.lua
180.443  require('config')
 054.532 require('config.pack')
 028.608 require('config.libs.editor')
 019.212 require('cmds.python_autoset_path')     <-- item A
 018.982 require('config.cores.dap')
```

**(B)** `nvim/lua/config/cores/treesitter.lua` — the entire file:

```lua
-- Enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Disable treesitter highlight for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 100 * 1024 then
      vim.treesitter.stop(args.buf)
    end
  end,
})
```

Neovim's autocmd order when opening a file is `BufReadPre` → `BufReadPost` → `FileType`. The stop
therefore always precedes the start.

## Why this approach

**(A) Move the lookup into the callback, key it off the buffer, and drop the subprocess.**
Neovim 0.12 provides `vim.fs.root(bufnr, '.git')`, which walks up from a given buffer's directory
and needs no `git` process at all. That removes the startup cost, fixes the stderr leak (no
subprocess), and fixes the wrong-value bug (resolved per buffer rather than once at launch).

Memoise per resolved root so repeated `BufEnter` events on the same project do not re-walk the
filesystem. `BufEnter` fires often — every window switch into the buffer — so an unmemoised
filesystem walk would trade one startup cost for many small ones.

Rejected: keeping `io.popen` but moving it into the callback. That fixes the startup cost and the
wrong-value bug but keeps a fork per project and still leaks stderr unless `2>/dev/null` is bolted
on. `vim.fs.root` is strictly better and is what the runtime provides for this.

Note `vim.env.PYTHONPATH` mutates the **whole Neovim process** environment, which every subprocess
inherits. Scoping it per-buffer would be more correct still, but that means threading it into LSP
and DAP client `cmd_env` — a larger change with a real behavior difference. **Out of scope**; this
plan preserves the existing process-level assignment and fixes only the three defects above.

**(B) Do the size check inside the `FileType` callback, before starting treesitter.**
That is the only place the ordering works, because it is the handler that actually starts
treesitter. Deleting the `BufReadPre` handler entirely is part of the fix — it can never do
anything useful where it is.

## Repo conventions to follow

- **Formatter:** StyLua, config at `nvim/.stylua.toml` — 120 columns, 2-space indent, Unix line
  endings, `AutoPreferSingle` quotes (prefer `'single'`), `call_parentheses = "Input"`.
- **Autocmds** live in `nvim/lua/cmds/`; plugin configuration lives in `nvim/lua/config/`. Do not
  move code between those trees.
- **Error handling:** `pcall` for anything that can fail, early return on failure. The existing
  `pcall(vim.uv.fs_stat, ...)` in `treesitter.lua` is the local exemplar.
- Entry-point `init.lua` files list requires only, no logic.

## Files in scope

- `nvim/lua/cmds/python_autoset_path.lua` — rewrite (item A).
- `nvim/lua/config/cores/treesitter.lua` — rewrite both autocmds into one (item B).

## Out of scope — do not touch

- `nvim/lua/utils/os_extend.lua` — after item A, its only remaining caller is
  `nvim/lua/functions/network.lua`, which uses it legitimately for two network lookups inside
  callbacks. **Do not delete or modify `os_extend.lua`.**
- `nvim/lua/functions/network.lua` — leave entirely alone.
- `nvim/lua/cmds/init.lua` — the require on line 2 stays; the module still exists, it just gets
  cheaper. (Line 3, `require 'cmds.rest'`, is removed by a *different* plan — if it is already gone
  when you get here, that is expected and fine.)
- `nvim/lua/config/cores/snacks.lua` — `bigfile = { enabled = true }` at line 4 is snacks' own
  large-file handling with its own threshold. It overlaps conceptually with item B. **Do not try to
  reconcile the two thresholds** — that needs a decision about which mechanism owns large files.
  Leave snacks alone.
- Any change to how `PYTHONPATH` is scoped (process vs buffer vs LSP `cmd_env`). See above.
- The other eager `require`s in `nvim/lua/config/init.lua` (dap, telescope, spectre). Deferring
  those is a separate, larger piece of work.
- Reformatting, renaming, or unrelated cleanups.

## Steps

### 1. Record the baseline

```bash
nvim --headless --startuptime /tmp/plan005-before.log +qa 2>&1
tail -2 /tmp/plan005-before.log
grep -E "python_autoset_path" /tmp/plan005-before.log
```
Record the total (last line) and the `python_autoset_path` figure. Expected at commit `9c7d0ed5`:
total around 230–245 ms, `python_autoset_path` around 17–20 ms.

Confirm startup output is otherwise clean:
```bash
nvim --headless +qa 2>&1
```
Expected: **either empty, or exactly this one line:**
```
vim.tbl_flatten is deprecated. Run ":checkhealth vim.deprecated" for more information
```
That is pre-existing noise from a third-party plugin, not in scope. Any *other* output means the
repo was already broken — record it and say so rather than fixing unrelated things.

Note: `nvim --headless +qa` **exits 0 even when the config throws.** Check the output text, never
the exit code.

Reproduce the stderr leak, so you can prove it is fixed later:
```bash
cd /tmp && nvim --headless +qa 2>&1 | grep -i "not a git repository" && echo "LEAK REPRODUCED"
cd /Users/louishuyng/.dotfiles
```
Expected: `LEAK REPRODUCED`. If it does not reproduce, note that and continue — the other two
problems still stand.

### 2. (A) Rewrite the Python path module

Rewrite `nvim/lua/cmds/python_autoset_path.lua` so that:

- Nothing runs at module load except registering the autocmd. No `io.popen`, no `require` of
  `utils.os_extend`.
- The `BufEnter` autocmd keeps `pattern = '*.py'`.
- Inside the callback, resolve the project root from **the event's buffer**, using
  `vim.fs.root(args.buf, '.git')`. Take `args` as the callback parameter.
- If `vim.fs.root` returns `nil` (the file is not in a git repository), **do not set
  `PYTHONPATH` at all** — return early. Do not set it to `/src`, and do not set it to the empty
  string. This is the fix for the current `/src` bug.
- If a root is found, set `vim.env.PYTHONPATH` to `<root>/src`. Build the path with
  `vim.fs.joinpath(root, 'src')` rather than string concatenation.
- Memoise: keep a module-local table mapping buffer number (or resolved directory) to the computed
  value, so repeated `BufEnter` on the same buffer does not re-walk the filesystem.

Verify it parses and startup is clean:
```bash
nvim --headless +qa 2>&1
```
Expected: empty, or only the `vim.tbl_flatten` line.

Verify the stderr leak is gone:
```bash
cd /tmp && nvim --headless +qa 2>&1 | grep -i "not a git repository" && echo "STILL LEAKING" || echo "leak fixed"
cd /Users/louishuyng/.dotfiles
```
Expected: `leak fixed`.

Verify `PYTHONPATH` is still set correctly inside a repo:
```bash
cd /Users/louishuyng/.dotfiles
printf 'x = 1\n' > /tmp/plan005.py
mkdir -p /tmp/plan005repo && cd /tmp/plan005repo && git init -q . && printf 'y = 2\n' > b.py
nvim --headless b.py -c 'lua vim.defer_fn(function() print("PYTHONPATH=" .. tostring(vim.env.PYTHONPATH)) end, 200)' -c 'sleep 500m' -c qa 2>&1 | tail -2
cd /Users/louishuyng/.dotfiles
```
Expected: `PYTHONPATH=/tmp/plan005repo/src` (or `/private/tmp/...`, which is the same path).

Verify it is *not* set for a Python file outside any repo:
```bash
nvim --headless /tmp/plan005.py -c 'lua vim.defer_fn(function() print("PYTHONPATH=" .. tostring(vim.env.PYTHONPATH)) end, 200)' -c 'sleep 500m' -c qa 2>&1 | tail -2
```
Expected: `PYTHONPATH=nil`, or the value inherited from your shell — **not** the literal `/src`.

### 3. (B) Move the size check into the `FileType` handler

Rewrite `nvim/lua/config/cores/treesitter.lua` so there is **one** autocmd on `FileType` that:

- Gets the buffer from `args.buf`.
- Stats the buffer's file with `pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))`.
- Returns early **without starting treesitter** if the stat succeeded and `stats.size` exceeds
  100 KB. Keep the existing `100 * 1024` expression so the threshold stays greppable.
- Otherwise calls `pcall(vim.treesitter.start, args.buf)`.

Delete the `BufReadPre` autocmd entirely — it cannot work where it is.

Keep the explanatory comments, updated to describe the new behavior, and add a short note about
*why* the check must live in the `FileType` handler (because `BufReadPre` runs before treesitter is
ever started). That note is what stops someone re-introducing the bug.

Verify a large file does **not** get treesitter, and a small one does:
```bash
python3 -c "print('local x = 1\n' * 12000)" > /tmp/plan005-big.lua
ls -l /tmp/plan005-big.lua   # confirm well over 102400 bytes
printf 'local x = 1\n' > /tmp/plan005-small.lua

nvim --headless /tmp/plan005-big.lua -c 'sleep 500m' \
  -c 'lua print("big: ts active = " .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil))' -c qa 2>&1 | tail -1

nvim --headless /tmp/plan005-small.lua -c 'sleep 500m' \
  -c 'lua print("small: ts active = " .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil))' -c qa 2>&1 | tail -1
```
Expected: `big: ts active = false` and `small: ts active = true`.

**If `big` reports `true`: STOP and report back** — the guard still is not firing.

**If `small` reports `false`:** the Lua parser may simply not be installed. Check with
`nvim --headless -c 'lua print(vim.treesitter.language.add("lua"))' -c qa`. If the parser is
missing, that is a pre-existing condition, not your bug — say so and rely on the `big` result.

### 4. Confirm the startup win

```bash
nvim --headless --startuptime /tmp/plan005-after.log +qa 2>&1
tail -2 /tmp/plan005-after.log
grep -E "python_autoset_path" /tmp/plan005-after.log
```
Expected: `python_autoset_path` drops from ~19 ms to near zero, and the total drops by roughly that
much. Report both before and after numbers.

Startup timing is noisy — run each three times and use the median rather than reporting a single
sample.

### 5. Format

```bash
stylua nvim/lua/cmds/python_autoset_path.lua nvim/lua/config/cores/treesitter.lua
stylua --check nvim/lua/cmds/python_autoset_path.lua nvim/lua/config/cores/treesitter.lua
```
Expected: the check exits 0.

Clean up:
```bash
rm -rf /tmp/plan005.py /tmp/plan005repo /tmp/plan005-big.lua /tmp/plan005-small.lua /tmp/plan005-*.log
```

## Test plan

There is no test suite in this repository and one is not wanted. The regression checks are the
behavioral assertions in steps 2 and 3 — each reproduces a specific reported failure and asserts it
no longer occurs:

- stderr leak outside a git repo → `leak fixed`
- `PYTHONPATH` correct inside a repo, unset outside one
- treesitter off for a >100 KB file, on for a small one
- `python_autoset_path` startup cost near zero

Record all of them in your report, with the before/after startup numbers.

## Done criteria

All must hold, run from the repo root (`/Users/louishuyng/.dotfiles`):

```bash
# A: no subprocess, no os_extend dependency, no naive concatenation
grep -n "io.popen\|os_extend\|rev-parse" nvim/lua/cmds/python_autoset_path.lua ; test $? -eq 1 && echo ok
grep -n "vim.fs.root" nvim/lua/cmds/python_autoset_path.lua    # should match

# A: os_extend itself is untouched and still used by network.lua
test -e nvim/lua/utils/os_extend.lua && echo ok
grep -rn "os_extend" nvim/lua/functions/network.lua            # should still match

# B: the BufReadPre handler is gone, one FileType handler remains
grep -c "nvim_create_autocmd" nvim/lua/config/cores/treesitter.lua   # should print 1
grep -n "BufReadPre" nvim/lua/config/cores/treesitter.lua ; test $? -eq 1 && echo ok
grep -n "100 \* 1024" nvim/lua/config/cores/treesitter.lua           # should match

# Startup clean (empty, or only the tbl_flatten line)
nvim --headless +qa 2>&1

# No stderr leak outside a repo
cd /tmp && nvim --headless +qa 2>&1 | grep -ci "not a git repository"   # should print 0
cd /Users/louishuyng/.dotfiles

# Formatting
stylua --check nvim/lua/cmds/python_autoset_path.lua nvim/lua/config/cores/treesitter.lua

# Scope
git status --porcelain
```

For the scope check, the only files your work may add to the modified list are
`nvim/lua/cmds/python_autoset_path.lua` and `nvim/lua/config/cores/treesitter.lua`. The repo has
pre-existing uncommitted changes to other files — including
`nvim/lua/config/theme/adapters/cendre.lua` — which are the user's own work. Leave them untouched
and do not commit anything.

## Escape hatches

STOP and report back instead of improvising if:

- The step 1 baseline shows errors beyond the `vim.tbl_flatten` line.
- `vim.fs.root` is unavailable (check:
  `nvim --headless -c 'lua print(type(vim.fs.root))' -c qa` — expected `function`). Do not fall back
  to `io.popen`; report the version mismatch.
- Step 3's large-file check still reports `ts active = true` after your change.
- Fixing either item appears to require touching a file listed as out of scope — in particular
  `nvim/lua/utils/os_extend.lua` or `nvim/lua/config/cores/snacks.lua`.
- `stylua` is not installed (report it; do not hand-format).

## Drift check

This plan was written against commit `9c7d0ed5`. Before starting:

```bash
git log --oneline 9c7d0ed5..HEAD -- \
  nvim/lua/cmds/python_autoset_path.lua \
  nvim/lua/config/cores/treesitter.lua \
  nvim/lua/utils/os_extend.lua
```

If that lists commits, the excerpts and line numbers above may be stale. Read the current files
first; if they have materially changed, report that rather than executing.

## Post-execution correction — item B does NOT achieve its stated goal

**Added after execution, 2026-08-10. This plan's premise for item B was wrong.**

Item A landed and is fully verified: `python_autoset_path` self-time went from **~19 ms to 0.084 ms**,
the stderr leak outside a git repo is gone, and `PYTHONPATH` is now resolved per buffer (correct
inside a repo, unset outside one instead of the literal `/src`).

Item B is a **real but insufficient** fix. The autocmd-ordering bug was genuine — the `BufReadPre`
handler was provably a no-op — and removing it plus guarding inside `FileType` is strictly better
than before. But the observable goal, "large files get no treesitter," is **not** achieved, because
the config is not the only thing that starts treesitter. Traced by wrapping `vim.treesitter.start`:

```
>>> TS START called buf=1
	.../snacks.nvim/lua/snacks/quickfile.lua:40: in function 'setup'

>>> TS START called buf=nil
	.../neovim/0.12.4/share/nvim/runtime/ftplugin/lua.lua:2: in main chunk
```

Two independent callers, neither of which a config-side `FileType` guard can prevent:

1. **Neovim 0.12's own `$VIMRUNTIME/ftplugin/lua.lua`** calls `vim.treesitter.start()` directly.
   Any filetype shipping a treesitter-enabled runtime ftplugin behaves this way.
2. **`snacks.quickfile`** (`quickfile = { enabled = true }` in `nvim/lua/config/cores/snacks.lua`)
   calls `pcall(vim.treesitter.start, buf, lang)` to render early. Its size ceiling comes from
   snacks' `bigfile` option, which defaults to **1.5 MB** — so a 144 KB file is not "big" to snacks.

Verified empirically: a 144 KB `.lua` file still reports `ts active = true` after item B, and still
does with `quickfile` disabled (because the runtime ftplugin alone is sufficient).

**Consequence:** the 100 KB threshold in this file now only governs filetypes with no ts-enabled
runtime ftplugin and no snacks early-render. It is not a general large-file guard.

**What a real fix looks like** (a new plan, not a patch to this one): stop treesitter *after* the
fact rather than declining to start it — e.g. a `BufWinEnter`/`FileType` handler with `nested`
ordering that calls `vim.treesitter.stop(buf)` for oversized buffers — or simply lower snacks'
`bigfile.size` to the desired threshold and delete the hand-rolled guard entirely, letting one
mechanism own large-file behavior. The second option is probably right: this repo already has two
competing thresholds, which is the underlying problem.

## Maintenance note

Two rules this establishes, both worth enforcing in review:

1. **Nothing at Lua module scope may fork a process or block on I/O.** Module bodies run during
   `require`, which is the startup critical path. Work belongs inside the autocmd, keymap, or
   command callback that needs it. Item A was exactly this mistake, and it was the single most
   expensive non-plugin module in the config.
2. **A guard must run in the same event that performs the thing it guards.** Item B failed because
   the `stop` lived on `BufReadPre` while the `start` lived on `FileType`, and `BufReadPre` always
   runs first. When adding an autocmd that disables something, put it where the enabling happens.

Two related things left deliberately untouched:

- **`PYTHONPATH` is still process-wide.** `vim.env` mutates the Neovim process environment, so every
  subprocess — LSP servers, DAP adapters, formatters, `:terminal` — inherits it. That is a broader
  design question than this fix.
- **Snacks' `bigfile` handling** (`nvim/lua/config/cores/snacks.lua:4`) has its own large-file
  threshold independent of the 100 KB used here. Once item B actually works, the two mechanisms are
  both live and may disagree about a given file. Reconciling them — deciding which one owns
  large-file behavior — is worth doing, but it is a decision, not a bug fix.
