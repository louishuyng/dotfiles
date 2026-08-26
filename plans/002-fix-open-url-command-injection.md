# 002 — Fix the command injection in "open URL under cursor"

- **Status:** TODO
- **Category:** security
- **Severity:** critical
- **Effort:** S
- **Fix risk:** low
- **Written against commit:** `9c7d0ed5`
- **Depends on:** none

## Problem

This is a personal dotfiles repository. Its Neovim configuration provides a keymap, `<leader>ou`
(leader is Space, so: `Space` then `o` then `u`), which extracts a URL from the current line and
opens it in the system browser via macOS's `open` command.

The implementation builds a shell command by string concatenation and gets the quoting wrong in a
way that cancels out its own escaping. The result is arbitrary command execution: pressing
`<leader>ou` while the cursor is on a crafted line runs whatever commands that line contains.

The mechanism is a double-quoting mistake. Vimscript's `shellescape(s:uri, 1)` **already returns a
single-quoted string** — that is its entire job. The code then wraps that already-quoted string in
another pair of single quotes. For a line containing:

```
http://example.com`id`
```

`shellescape` produces `'http://example.com`id`'`, and the final command becomes:

```sh
open ''http://example.com`id`''
```

The shell parses the leading `''` as an empty string that closes immediately, which leaves the
backticks **outside** any quoting — so `` `id` `` is executed as a command substitution.

The URL-extraction pattern is `[a-z]*:\/\/[^ >,;()]*`, which excludes `;`, `(`, and `)` — so
`$(...)` is blocked — but it permits backticks, `&`, `|`, and `>`. Backtick command substitution
and `&` command chaining both get through.

The realistic attack: open any file you did not write — a README in a cloned repository, a log
file, a source file, a downloaded text file — put the cursor on a line, press `<leader>ou`. The
commands run as your user.

## Evidence

`nvim/plugin/openurl.vim` — the entire file, at commit `9c7d0ed5`. Note line 3 escaping and line 6
re-quoting the already-escaped result:

```vim
function! OpenUrlUnderCursor()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;()]*')
  let s:uri = shellescape(s:uri, 1)
  echom s:uri
  if s:uri != ""
    silent exec "!open '".s:uri."'"
    :redraw!
  else
    echo "No URI found in line."
  endif
endfunction
```

`nvim/lua/mappings/editor/general.lua:77-82` — the keymap that reaches it:

```lua
vim.keymap.set(
  'n',
  '<leader>ou',
  ':call OpenUrlUnderCursor()<CR>',
  { silent = true, noremap = true, desc = 'Open url under cursor' }
)
```

Files under `nvim/plugin/` are sourced automatically by Neovim at startup, so this function is
always defined.

## Why this approach

Replace the whole Vimscript function with `vim.ui.open()`, which Neovim has provided as a built-in
since 0.10. This repository runs Neovim 0.12.

`vim.ui.open()` takes the URL as a value and dispatches to the platform opener (`open` on macOS)
**without going through a shell at all**. There is no string to quote, so the bug class is
eliminated rather than patched. It is also less code and is the idiomatic modern replacement.

Rejected alternatives:

- *Just remove the outer quotes* (`exec "!open " . shellescape(s:uri, 1)`). This fixes the specific
  bug and is a one-character-class change, but it keeps a shell in the loop and keeps the whole
  thing in Vimscript for no benefit. It also leaves the next person to re-derive why the quoting is
  the way it is.
- *`vim.system({'open', uri})`*. Also safe (argv list, no shell), but hardcodes macOS. `vim.ui.open`
  does the same thing portably and is the documented API for exactly this.

## Repo conventions to follow

- **Formatter:** StyLua, config at `nvim/.stylua.toml` — 120 columns, 2-space indent,
  `AutoPreferSingle` quotes (prefer `'single'`).
- **Keymaps:** the documented pattern is `vim.keymap.set(mode, lhs, rhs, opts)` with a `desc` field
  on every mapping for which-key discoverability. Leader is Space, local leader is Comma. The
  existing block at `nvim/lua/mappings/editor/general.lua:77-82` (quoted above) is the exemplar for
  shape and option style — keep `silent`, `noremap`, and `desc`.
- **Error handling:** early-return on failure; `vim.notify` with an explicit `vim.log.levels.*` for
  user-visible messages. See `nvim/lua/config/theme/init.lua:80` for the house style.

## Files in scope

- `nvim/plugin/openurl.vim` — delete this file.
- `nvim/lua/mappings/editor/general.lua` — replace the keymap's right-hand side with a Lua function.

## Out of scope — do not touch

- `nvim/plugin/gotowindow.vim` — a separate Vimscript file in the same directory with its own
  problems (it calls a plugin that is not installed). It is tracked separately. Leave it alone even
  though it looks like the same kind of cleanup.
- `nvim/lua/config/cores/test.lua` — builds shell strings by concatenation in a similar unsafe way.
  Tracked separately. Do not fix it here.
- `nvim/lua/config/cores/telescope/custom/nest_js.lua` — same, tracked separately.
- Any other keymap in `nvim/lua/mappings/editor/general.lua`. Change only the `<leader>ou` block.
- Reformatting, renaming, or unrelated cleanups.

## Steps

### 1. Confirm the current behavior exists as described

```bash
cat nvim/plugin/openurl.vim
grep -n "OpenUrlUnderCursor" -r nvim/
```

Expected: the file matches the Evidence section, and `grep` reports exactly two locations — the
definition in `nvim/plugin/openurl.vim:1` and the keymap in
`nvim/lua/mappings/editor/general.lua:80`.

**If `grep` finds other callers: STOP and report back.** This plan assumes the function has exactly
one call site.

### 2. Replace the keymap right-hand side with a shell-free Lua implementation

In `nvim/lua/mappings/editor/general.lua`, replace the `<leader>ou` block (lines 77-82, quoted in
Evidence) with a `vim.keymap.set` whose right-hand side is a Lua function that:

- Extracts the URL from the current line. Use `vim.fn.matchstr(vim.api.nvim_get_current_line(), ...)`
  with the **same** pattern the Vimscript used: `[a-z]*:\/\/[^ >,;()]*`. Keeping the pattern
  identical means behavior does not change for legitimate URLs.
- If the result is an empty string, calls `vim.notify` at `vim.log.levels.INFO` with a message like
  `No URI found in line.` (preserving the original's user-facing text) and returns.
- Otherwise calls `vim.ui.open(uri)`.
- Keeps `silent = true`, `noremap = true`, and `desc = 'Open url under cursor'`.

Do **not** pass the URL through `shellescape`, `vim.fn.system`, `:!`, or any string concatenation
into a command. The whole point is that no shell is involved.

Verify it parses and the mapping is registered:
```bash
nvim --headless -c 'lua print(vim.fn.maparg("<leader>ou", "n") ~= "" and "mapped" or "MISSING")' -c qa 2>&1
```
Expected: `mapped` (plus possibly the known deprecation line — see step 5).

### 3. Delete the Vimscript file

```bash
git rm nvim/plugin/openurl.vim
```

Expected: the file is staged for deletion. (Using `git rm` rather than `rm` because the file is
tracked.)

### 4. Confirm nothing still references the removed function

```bash
grep -rn "OpenUrlUnderCursor" nvim/ ; echo "exit=$?"
```
Expected: no output, `exit=1`.

### 5. Confirm Neovim starts clean

```bash
nvim --headless +qa 2>&1
```

Expected: **either completely empty, or exactly this one line and nothing else:**
```
vim.tbl_flatten is deprecated. Run ":checkhealth vim.deprecated" for more information
```

That deprecation line is **pre-existing noise from a third-party plugin**, present at commit
`9c7d0ed5` before your change. Not your problem, not in scope. Any *other* stderr output means
something broke — investigate before continuing.

Note that `nvim --headless +qa` **exits 0 even when the config throws**, so check the output text,
never the exit code.

### 6. Verify the fix behaviorally

Confirm a malicious line no longer executes anything. Create a scratch file outside the repo:

```bash
printf 'see http://example.com`touch /tmp/PLAN002_PWNED`\n' > /tmp/plan002-test.txt
rm -f /tmp/PLAN002_PWNED
```

Then open it and trigger the mapping headlessly:

```bash
nvim --headless /tmp/plan002-test.txt -c 'normal  ou' -c 'sleep 500m' -c qa 2>&1
ls /tmp/PLAN002_PWNED 2>/dev/null && echo "STILL VULNERABLE" || echo "safe: no command executed"
```

Expected: `safe: no command executed`.

**If it prints `STILL VULNERABLE`: STOP and report back.**

Note: `vim.ui.open` may genuinely try to open a browser window during this test, since the URL is
syntactically valid. That is expected and harmless. Clean up afterwards:
```bash
rm -f /tmp/plan002-test.txt /tmp/PLAN002_PWNED
```

### 7. Format

```bash
stylua nvim/lua/mappings/editor/general.lua
stylua --check nvim/lua/mappings/editor/general.lua
```
Expected: the check exits 0.

Be aware `nvim/lua/mappings/editor/general.lua` is one of twelve files in the repo that currently
**fail** `stylua --check` at commit `9c7d0ed5`. Running `stylua` on it will therefore produce
formatting changes beyond your edit. That is acceptable and expected for this one file — say so in
your report so the reviewer knows why the diff is larger than the logical change.

## Test plan

There is no test suite in this repository and one is not wanted. Step 6 is the regression test: it
reproduces the exploit against the fixed code and asserts nothing executes. Record its output in
your report.

## Done criteria

All must hold, run from the repo root (`/Users/louishuyng/.dotfiles`):

```bash
# 1. The vulnerable file is gone
test ! -e nvim/plugin/openurl.vim && echo ok

# 2. Nothing references the removed function
grep -rn "OpenUrlUnderCursor" nvim/ ; test $? -eq 1 && echo ok

# 3. No shell-based open remains in the changed file
grep -n "shellescape\|!open" nvim/lua/mappings/editor/general.lua ; test $? -eq 1 && echo ok

# 4. The mapping still exists
nvim --headless -c 'lua print(vim.fn.maparg("<leader>ou","n") ~= "" and "mapped" or "MISSING")' -c qa 2>&1

# 5. Startup is clean (empty, or only the tbl_flatten line)
nvim --headless +qa 2>&1

# 6. Formatting is clean
stylua --check nvim/lua/mappings/editor/general.lua

# 7. Scope
git status --porcelain
```

For #7: the only paths your work may touch are `nvim/plugin/openurl.vim` (deleted) and
`nvim/lua/mappings/editor/general.lua` (modified). The repo has pre-existing uncommitted changes to
other files — including `nvim/lua/config/theme/adapters/cendre.lua` — which are the user's own
work. Leave them untouched. Do not commit anything.

## Escape hatches

STOP and report back instead of improvising if:

- Step 1 finds callers of `OpenUrlUnderCursor` beyond the single keymap.
- Step 6 prints `STILL VULNERABLE`.
- `vim.ui.open` is not available in the installed Neovim (check with
  `nvim --headless -c 'lua print(type(vim.ui.open))' -c qa` — expected `function`). If it is `nil`,
  the Neovim version is older than assumed; report rather than falling back to a shell.
- `stylua` is not installed (report it; do not hand-format).
- Fixing this appears to require changing a file listed as out of scope.

## Drift check

This plan was written against commit `9c7d0ed5`. Before starting:

```bash
git log --oneline 9c7d0ed5..HEAD -- nvim/plugin/openurl.vim nvim/lua/mappings/editor/general.lua
```

If that lists commits, the excerpts and line numbers above may be stale. Read the current files
first; if they have materially changed, report that rather than executing.

## Maintenance note

The rule this establishes: **never build a shell command by concatenating a value into a string.**
Use an argv list (`vim.system({...})`) or a purpose-built API (`vim.ui.open`). Reviewers should
reject `vim.fn.system('cmd ' .. value)` and `exec "!cmd " . value` on sight.

Two other places in this config still have the same shape and are tracked separately:
`nvim/lua/config/cores/test.lua:28-43` (builds `wezterm cli send-text` strings from the test
command, which contains buffer file paths) and
`nvim/lua/config/cores/telescope/custom/nest_js.lua:29-38` (interpolates into `io.popen`, currently
unreachable because its only caller is commented out). When either is fixed, follow the pattern
established here rather than inventing a new one.
