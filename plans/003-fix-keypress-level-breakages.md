# 003 — Fix three things that break on a keypress

- **Status:** TODO
- **Category:** correctness
- **Severity:** high
- **Effort:** S
- **Fix risk:** low
- **Written against commit:** `9c7d0ed5`
- **Depends on:** none

## Problem

This is a personal dotfiles repository; the Neovim config lives in `nvim/`. Three independent
defects each produce a visible failure during ordinary editing. They are grouped into one plan
because each is a few lines, they do not interact, and they share the same verification setup.

**(A) Every `.txt` file forks `npx` at a path that does not exist.**
`nvim/after/ftplugin/text.lua` unconditionally starts an LSP client whose command is
`npx ts-node <path>`. Files under `after/ftplugin/` run for **every buffer** of that filetype, so
opening any text file spawns `npx`, which resolves the npm registry and then fails because the
server path is absent from this machine. The user sees a spawn error and a stall, repeatedly. It
also collides with `typos_lsp`, which already claims the `text` filetype
(`nvim/lua/config/lsp/servers/spell.lua`).

**(B) LSP keymaps get silently dropped, sometimes from the wrong buffer.**
The `LspAttach` handler correctly receives the attaching buffer as `ev.buf`, but its early-return
guard tests `vim.fn.expand('%:t')` — the filename of the buffer in the **currently focused window**,
which is not necessarily the buffer the client attached to. Two failures follow. First, opening any
dotfile (`.env`, `.gitignore`, `.eslintrc.json`) returns early and that buffer loses every LSP
keymap: `gf`, `gd`, `gi`, `gt`, `gS`, `<leader>ca`, `,rr`, `gl`. Second and worse, `LspAttach` also
fires for buffers loaded in the background — quickfix jumps, `:bufdo`, Telescope previews,
`:oldfiles`. If a dotfile happens to be focused at that moment, an unrelated **source** buffer gets
no LSP keymaps at all, with no error and no clue why. The state persists until the buffer is
reloaded. The comment above the guard says "don't format", which is not what the code does.

**(C) `<CR>` is rebound in every `.http` buffer to a command that does not exist.**
`nvim/lua/cmds/rest.lua` binds `<CR>` and `<space>rl` in `*.http` buffers to `:Rest run`. The
`rest-nvim` plugin is **not** in `nvim/lua/config/pack.lua` and is not installed. The related
config module `nvim/lua/config/libs/rest.lua` pcall-guards its require and silently returns, so
nothing complains at startup — but pressing Enter in a `.http` file, the ordinary way to move the
cursor down, throws `E492: Not an editor command: Rest`.

## Evidence

**(A)** `nvim/after/ftplugin/text.lua` — the entire file, at commit `9c7d0ed5`:

```lua
vim.lsp.start({
  name = "LSP From Scratch",
  cmd = {
    "npx", "ts-node",
    vim.fn.expand(
      "~/Dev/repository/github.com/louishuyng/awesome-tech/backend/scratch/lsp-from-scratch/server/src/server.ts")
  },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})
```

The path does not exist. Verified at commit `9c7d0ed5`:
```
$ ls -d ~/Dev/repository/github.com/louishuyng/awesome-tech
"/Users/louishuyng/Dev/repository/github.com/louishuyng/awesome-tech": No such file or directory
```

**(B)** `nvim/lua/config/lsp/on_attach.lua:5-18` — `bufnr` is taken from `ev.buf` on line 6, but the
guard on line 14 reads the *current window's* file name:

```lua
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then
      return
    end

    -- If file has . characters at beginning, don't format
    if vim.fn.match(vim.fn.expand('%:t'), '^[.]') ~= -1 then
      return
    end

    local opts = { buffer = bufnr, silent = true, noremap = true }
```

**(C)** `nvim/lua/cmds/rest.lua` — the entire file:

```lua
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.http",
    callback = function()
        vim.keymap.set('n', '<CR>', ':hor Rest run<CR>', { buffer = true })
        vim.keymap.set('n', '<space>rl', ':hor Rest run last<CR>', { buffer = true })
    end,
})
```

`nvim/lua/config/libs/rest.lua` pcall-guards the plugin and returns early, which is why the missing
plugin is invisible at startup. Neither `rest-nvim` nor any REST client appears in
`nvim/lua/config/pack.lua`.

## Why this approach

- **(A) Delete the file.** It is one developer's scratch experiment pointing at a directory that no
  longer exists on this machine, and the filetype it targets is already served by `typos_lsp`.
  Salvaging it would mean guarding on `vim.uv.fs_stat` plus a project marker — real work for a
  feature the user is not using. If it is ever wanted back, it is one `git show` away.
- **(B) Read the name off the attaching buffer, and move the guard to what it was meant to gate.**
  The buffer mix-up is unambiguous and must be fixed. The *intent* is ambiguous: the comment says
  "don't format" but the code skips keymaps. Because the intent cannot be recovered from the code,
  this plan takes the conservative reading — fix the buffer bug, keep the guard where it is, and do
  **not** relocate it to the formatter. Moving it would change formatting behavior for dotfiles,
  which is a product decision the user has not made.
- **(C) Delete the dead REST wiring.** The plugin is absent, so every code path is broken.
  Rebinding `<CR>` in a normal buffer is user-hostile even when the target command works, so this
  is worth removing rather than repairing on spec. Re-adding the plugin is a feature request, not a
  bug fix.

## Repo conventions to follow

- **Formatter:** StyLua, config at `nvim/.stylua.toml` — 120 columns, 2-space indent, Unix line
  endings, `AutoPreferSingle` quotes (prefer `'single'`), `call_parentheses = "Input"`.
- **Keymaps:** `vim.keymap.set(mode, lhs, rhs, opts)` with a `desc` on every mapping. The block at
  `nvim/lua/config/lsp/on_attach.lua:20-21` is the exemplar for the buffer-local LSP style:
  ```lua
  vim.keymap.set('n', 'gf', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
  ```
- **Guarding against nil:** early return, as at `on_attach.lua:9-11`.
- Entry-point files (`init.lua`) contain only requires and no logic — respect that when removing a
  require from `nvim/lua/config/init.lua`.

## Files in scope

- `nvim/after/ftplugin/text.lua` — delete (item A).
- `nvim/lua/config/lsp/on_attach.lua` — fix the guard (item B).
- `nvim/lua/cmds/rest.lua` — delete (item C).
- `nvim/lua/config/libs/rest.lua` — delete (item C).
- `nvim/lua/config/init.lua` — remove the now-dangling `require('config.libs.rest')` (item C).
- `nvim/lua/cmds/init.lua` — remove the now-dangling require of `cmds.rest` (item C).

## Out of scope — do not touch

- `nvim/lua/config/pack.lua` — do **not** add `rest-nvim` or any other plugin.
- `nvim/lua/config/lsp/register_formatters.lua` — do **not** move the dotfile guard into the
  formatter, even though the comment hints at it. See "Why this approach".
- `nvim/snippets/hurl.json` — a snippet file related to the REST workflow. Leave it; it is inert and
  removing it is a separate decision.
- `nvim/lua/mappings/editor/telescope.lua` — contains a `<leader>fa` picker for `.http` files.
  Leave it. It still works (it just finds files) and removing it is a separate decision.
- `nvim/lua/config/lsp/servers/spell.lua` — the `typos_lsp` config that also claims `text`. It is
  correct as-is; item A is what conflicts with it, and item A is being deleted.
- The duplicate `gi` keymap (registered identically at `on_attach.lua:23-28` and `:46-51`) and the
  `gv` keymap at `:39-44` that omits `opts` and is therefore global rather than buffer-local. Both
  are real minor defects, both are tracked separately. **Do not fix them here** — this plan's diff
  must stay reviewable.
- Reformatting, renaming, or unrelated cleanups anywhere.

## Steps

### 1. Record the baseline

Before changing anything, capture what a clean startup looks like:

```bash
nvim --headless +qa 2>&1
```

Expected at commit `9c7d0ed5`: **either empty, or exactly this one line:**
```
vim.tbl_flatten is deprecated. Run ":checkhealth vim.deprecated" for more information
```

That line is pre-existing noise from a third-party plugin. It is not in scope. Any *other* output
means the repo was already broken before you started — record it and say so in your report rather
than trying to fix it.

Note: `nvim --headless +qa` **exits 0 even when the config throws**. Always check the output text,
never the exit code.

### 2. (A) Delete the scratch LSP ftplugin

```bash
git rm nvim/after/ftplugin/text.lua
```

Confirm nothing else references it:
```bash
grep -rn "lsp-from-scratch\|LSP From Scratch" nvim/ ; echo "exit=$?"
```
Expected: no output, `exit=1`.

Confirm opening a text file no longer tries to spawn anything:
```bash
printf 'hello\n' > /tmp/plan003.txt
nvim --headless /tmp/plan003.txt -c 'sleep 300m' -c qa 2>&1
```
Expected: empty, or only the `vim.tbl_flatten` line. Specifically **no** `npx`, `ENOENT`, or
`ts-node` in the output.

### 3. (B) Read the guard's filename from the attaching buffer

In `nvim/lua/config/lsp/on_attach.lua`, change the guard on line 14 so that it tests the **name of
`bufnr`** (which is `ev.buf`), not the current window's file.

Use `vim.api.nvim_buf_get_name(bufnr)` to get the full path and `vim.fs.basename(...)` to reduce it
to the filename, then apply the same "starts with a dot" test. Keep the guard's position and
behavior otherwise identical — it should still `return` early for dotfiles.

Also update the comment above it so it describes what the code does. It currently says
"If file has . characters at beginning, don't format", but the code skips keymap registration.
Write a comment that states the actual behavior, and note the uncertainty, e.g. that the original
intent may have been about formatting.

Verify the file parses and startup is clean:
```bash
nvim --headless +qa 2>&1
```
Expected: empty, or only the `vim.tbl_flatten` line.

Verify the guard now keys off the right buffer. This test opens a real source file while a dotfile
is *also* loaded, and asserts the source buffer still gets its LSP keymaps:

```bash
cd /Users/louishuyng/.dotfiles
nvim --headless nvim/lua/config/theme/palette.lua \
  -c 'sleep 2' \
  -c 'lua print("gf mapped: " .. tostring(vim.fn.maparg("gf","n") ~= ""))' \
  -c qa 2>&1
```
Expected: a line reading `gf mapped: true`.

**If it prints `gf mapped: false`: STOP and report back.** Either lua_ls did not attach within the
sleep window (try increasing it to `sleep 4`) or the change is wrong. Distinguish the two before
reporting.

### 4. (C) Remove the dead REST wiring

Delete the two modules:
```bash
git rm nvim/lua/cmds/rest.lua nvim/lua/config/libs/rest.lua
```

Then remove the requires that pointed at them. Find them first:
```bash
grep -rn "cmds.rest\|cmds/rest\|libs.rest\|libs/rest" nvim/
```

Expected: two hits — one in `nvim/lua/cmds/init.lua` and one in `nvim/lua/config/init.lua` (at
`nvim/lua/config/init.lua:47` at the time of writing, the line `require('config.libs.rest')`).
Remove those lines. Do not leave a commented-out require behind — see the maintenance note.

Confirm the references are gone:
```bash
grep -rn "cmds.rest\|cmds/rest\|libs.rest\|libs/rest\|Rest run" nvim/ ; echo "exit=$?"
```
Expected: no output, `exit=1`.

Confirm `<CR>` is no longer hijacked in `.http` buffers:
```bash
printf 'GET http://example.com\n' > /tmp/plan003.http
nvim --headless /tmp/plan003.http -c 'sleep 300m' \
  -c 'lua print("CR remapped: " .. tostring(vim.fn.maparg("<CR>","n") ~= ""))' -c qa 2>&1
```
Expected: `CR remapped: false`.

### 5. Format the one file you edited

```bash
stylua nvim/lua/config/lsp/on_attach.lua
stylua --check nvim/lua/config/lsp/on_attach.lua
```
Expected: the check exits 0.

### 6. Final startup check

```bash
nvim --headless +qa 2>&1
```
Expected: identical to the step 1 baseline.

Clean up scratch files:
```bash
rm -f /tmp/plan003.txt /tmp/plan003.http
```

## Test plan

There is no test suite in this repository and one is not wanted. The behavioral checks in steps
2, 3, and 4 are the regression tests — each reproduces the reported failure condition and asserts
it no longer occurs. Record all three outputs in your report.

## Done criteria

All must hold, run from the repo root (`/Users/louishuyng/.dotfiles`):

```bash
# A: deleted, no references
test ! -e nvim/after/ftplugin/text.lua && echo ok
grep -rn "lsp-from-scratch" nvim/ ; test $? -eq 1 && echo ok

# B: guard no longer reads the current window's filename
grep -n "expand('%:t')" nvim/lua/config/lsp/on_attach.lua ; test $? -eq 1 && echo ok
grep -n "nvim_buf_get_name" nvim/lua/config/lsp/on_attach.lua   # should match

# C: deleted, no dangling requires
test ! -e nvim/lua/cmds/rest.lua && echo ok
test ! -e nvim/lua/config/libs/rest.lua && echo ok
grep -rn "cmds.rest\|libs.rest\|Rest run" nvim/ ; test $? -eq 1 && echo ok

# Startup clean (empty, or only the tbl_flatten line)
nvim --headless +qa 2>&1

# Formatting
stylua --check nvim/lua/config/lsp/on_attach.lua

# Scope
git status --porcelain
```

For the scope check, the only paths your work may touch are the six listed under "Files in scope".
The repo has pre-existing uncommitted changes to unrelated files — including
`nvim/lua/config/theme/adapters/cendre.lua` — which are the user's own work. Leave them untouched.
Do not commit anything.

## Escape hatches

STOP and report back instead of improvising if:

- The step 1 baseline shows errors beyond the `vim.tbl_flatten` line — the repo was already broken;
  record the baseline and stop rather than fixing unrelated things.
- Step 3's check prints `gf mapped: false` even after increasing the sleep to 4 seconds.
- `grep` in step 4 finds requires of `cmds.rest` or `libs.rest` in files other than
  `nvim/lua/cmds/init.lua` and `nvim/lua/config/init.lua`.
- Removing item C appears to break something else — for example if some other module calls a
  function defined in `nvim/lua/config/libs/rest.lua`.
- Any Evidence excerpt does not match the current file contents.
- `stylua` is not installed (report it; do not hand-format).

## Drift check

This plan was written against commit `9c7d0ed5`. Before starting:

```bash
git log --oneline 9c7d0ed5..HEAD -- \
  nvim/after/ftplugin/text.lua \
  nvim/lua/config/lsp/on_attach.lua \
  nvim/lua/cmds/rest.lua \
  nvim/lua/config/libs/rest.lua \
  nvim/lua/config/init.lua \
  nvim/lua/cmds/init.lua
```

If that lists commits, the excerpts and line numbers above may be stale. Read the current files
first; if they have materially changed, report that rather than executing.

## Maintenance note

**Do not replace the deleted code with commented-out code.** `AGENTS.md:113` currently instructs
"Comment out unused plugins rather than deleting them (preserves history)". That rule is the direct
cause of much of the dead code in this repo and is itself slated for removal; git history already
preserves everything. Delete cleanly.

Two patterns for reviewers to watch going forward:

1. **`LspAttach` handlers must use `ev.buf`, never `expand('%')` or `nvim_get_current_buf()`.** The
   event fires for background buffers, so "the current buffer" and "the buffer being attached to"
   are different things. Item B was exactly this mistake.
2. **A `pcall`-guarded require that always fails is invisible breakage.** `libs/rest.lua` hid a
   missing plugin for however long, while `cmds/rest.lua` kept binding keys to its commands. When
   guarding an optional plugin, guard *everything* that depends on it, not just the require.

Related items deliberately left for separate work: the duplicate `gi` registration and the
non-buffer-local `gv` mapping in `on_attach.lua`, and the `<leader>fa` `.http` file picker in
`nvim/lua/mappings/editor/telescope.lua`.
