# cmp Kind Icons Codicon Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Swap every glyph in `icons.kinds` to a `nf-cod-symbol_*` codicon equivalent so the cmp completion popup adopts an Emacs `lsp-mode` / `company-mode` aesthetic, and add a `Default` fallback so unknown LSP kinds never render as `' nil '`.

**Architecture:** Two-file change. (1) `nvim/lua/config/libs/icons.lua` — rewrite the `kinds` subtable with codicon glyphs and add a `Default` fallback entry. (2) `nvim/lua/config/cores/cmp.lua` — change one line in the `formatting.format` callback to fall back to `icons.Default` when the kind isn't in the table. No tests (this is a Neovim Lua config change with visual-only output); verification is a Lua sanity-check script plus opening Neovim and triggering completion.

**Tech Stack:** Neovim 0.12, Lua, nvim-cmp, Nerd Fonts (codicon block U+EA60–U+EB6F).

**Spec:** `docs/superpowers/specs/2026-04-30-cmp-emacs-icons-design.md`

---

## File Structure

| File | Role | Change |
|---|---|---|
| `nvim/lua/config/libs/icons.lua` | Glyph registry | Rewrite `kinds` subtable; add `kinds.Default` |
| `nvim/lua/config/cores/cmp.lua` | cmp setup | Replace the icon-lookup line with a fallback-aware version |

---

## Codicon glyph reference

Used in Task 1. Every glyph is from the Nerd Fonts codicon block, written here as a Lua string literal (escape form `'\u{XXXX}'` and the actual character, both shown so implementer can verify).

| Kind | Codicon name | Codepoint | Lua escape |
|---|---|---|---|
| Array | symbol_array | U+EA8A | `'\u{ea8a} '` |
| Boolean | symbol_boolean | U+EA8F | `'\u{ea8f} '` |
| Class | symbol_class | U+EB5B | `'\u{eb5b} '` |
| Color | symbol_color | U+EB5C | `'\u{eb5c} '` |
| Constant | symbol_constant | U+EB5D | `'\u{eb5d} '` |
| Constructor | symbol_method | U+EA8C | `'\u{ea8c} '` |
| Enum | symbol_enum | U+EA95 | `'\u{ea95} '` |
| EnumMember | symbol_enum_member | U+EB5E | `'\u{eb5e} '` |
| Event | symbol_event | U+EA86 | `'\u{ea86} '` |
| Field | symbol_field | U+EB5F | `'\u{eb5f} '` |
| File | symbol_file | U+EB60 | `'\u{eb60} '` |
| Folder | folder | U+EA83 | `'\u{ea83} '` |
| Function | symbol_method | U+EA8C | `'\u{ea8c} '` |
| Interface | symbol_interface | U+EB61 | `'\u{eb61} '` |
| Key | symbol_key | U+EA93 | `'\u{ea93} '` |
| Keyword | symbol_keyword | U+EB62 | `'\u{eb62} '` |
| Method | symbol_method | U+EA8C | `'\u{ea8c} '` |
| Module | symbol_namespace | U+EA8B | `'\u{ea8b} '` |
| Namespace | symbol_namespace | U+EA8B | `'\u{ea8b} '` |
| Null | symbol_null | U+EA8D | `'\u{ea8d} '` |
| Number | symbol_numeric | U+EA90 | `'\u{ea90} '` |
| Object | symbol_namespace | U+EA8B | `'\u{ea8b} '` |
| Operator | symbol_operator | U+EB64 | `'\u{eb64} '` |
| Package | package | U+EB29 | `'\u{eb29} '` |
| Property | symbol_property | U+EB65 | `'\u{eb65} '` |
| Reference | symbol_reference | U+EA94 | `'\u{ea94} '` |
| Snippet | symbol_snippet | U+EB66 | `'\u{eb66} '` |
| String | symbol_string | U+EAB1 | `'\u{eab1} '` |
| Struct | symbol_structure | U+EA91 | `'\u{ea91} '` |
| Text | symbol_string | U+EAB1 | `'\u{eab1} '` |
| TypeParameter | symbol_parameter | U+EA92 | `'\u{ea92} '` |
| Unit | symbol_ruler | U+EA96 | `'\u{ea96} '` |
| Value | symbol_enum | U+EA95 | `'\u{ea95} '` |
| Variable | symbol_variable | U+EA88 | `'\u{ea88} '` |
| Control | symbol_misc | U+EB63 | `'\u{eb63} '` |
| Collapsed | chevron_right | U+EAB6 | `'\u{eab6} '` |
| Default | symbol_misc | U+EB63 | `'\u{eb63} '` |

**Preserved (AI completion brand glyphs — copy from current `icons.lua` verbatim):**
- Codeium = `'\u{f0626} '`
- Copilot = `'\u{f4b8} '`
- Supermaven = `'\u{f005} '`
- TabNine = `'\u{f03da} '`

---

## Task 1: Replace `icons.kinds` table with codicon mapping + `Default`

**Files:**
- Modify: `nvim/lua/config/libs/icons.lua:26-67` (the entire `kinds = { ... }` block)

- [ ] **Step 1: Read the current `kinds` block**

Run: `sed -n '26,67p' nvim/lua/config/libs/icons.lua`
Expected: prints the existing 41-key kinds subtable starting with `kinds = {` and ending with `},`.

- [ ] **Step 2: Replace the `kinds` block with codicon mapping**

Use the Edit tool to swap lines 26–67 of `nvim/lua/config/libs/icons.lua` with the block below. Preserve indentation (2 spaces) and the trailing comma after `}`. The replacement keeps the same 40 keys plus adds `Default`.

```lua
  kinds = {
    Array = '\u{ea8a} ',
    Boolean = '\u{ea8f} ',
    Class = '\u{eb5b} ',
    Codeium = '\u{f0626} ',
    Color = '\u{eb5c} ',
    Control = '\u{eb63} ',
    Collapsed = '\u{eab6} ',
    Constant = '\u{eb5d} ',
    Constructor = '\u{ea8c} ',
    Copilot = '\u{f4b8} ',
    Default = '\u{eb63} ',
    Enum = '\u{ea95} ',
    EnumMember = '\u{eb5e} ',
    Event = '\u{ea86} ',
    Field = '\u{eb5f} ',
    File = '\u{eb60} ',
    Folder = '\u{ea83} ',
    Function = '\u{ea8c} ',
    Interface = '\u{eb61} ',
    Key = '\u{ea93} ',
    Keyword = '\u{eb62} ',
    Method = '\u{ea8c} ',
    Module = '\u{ea8b} ',
    Namespace = '\u{ea8b} ',
    Null = '\u{ea8d} ',
    Number = '\u{ea90} ',
    Object = '\u{ea8b} ',
    Operator = '\u{eb64} ',
    Package = '\u{eb29} ',
    Property = '\u{eb65} ',
    Reference = '\u{ea94} ',
    Snippet = '\u{eb66} ',
    String = '\u{eab1} ',
    Struct = '\u{ea91} ',
    Supermaven = '\u{f005} ',
    TabNine = '\u{f03da} ',
    Text = '\u{eab1} ',
    TypeParameter = '\u{ea92} ',
    Unit = '\u{ea96} ',
    Value = '\u{ea95} ',
    Variable = '\u{ea88} ',
  },
```

- [ ] **Step 3: Verify all keys are present and non-empty**

Run this Lua check via the system Lua interpreter (it loads the file, walks the table, and asserts every value is a non-empty string):

```bash
lua -e '
package.path = package.path .. ";nvim/lua/?.lua;nvim/lua/?/init.lua"
local icons = dofile("nvim/lua/config/libs/icons.lua")
local expected = {
  "Array","Boolean","Class","Codeium","Color","Control","Collapsed",
  "Constant","Constructor","Copilot","Default","Enum","EnumMember","Event",
  "Field","File","Folder","Function","Interface","Key","Keyword","Method",
  "Module","Namespace","Null","Number","Object","Operator","Package",
  "Property","Reference","Snippet","String","Struct","Supermaven","TabNine",
  "Text","TypeParameter","Unit","Value","Variable",
}
local missing, empty = {}, {}
for _, k in ipairs(expected) do
  local v = icons.kinds[k]
  if v == nil then table.insert(missing, k)
  elseif type(v) ~= "string" or v:gsub("%s",""):len() == 0 then table.insert(empty, k) end
end
if #missing > 0 then print("MISSING: " .. table.concat(missing, ", ")) os.exit(1) end
if #empty > 0 then print("EMPTY: " .. table.concat(empty, ", ")) os.exit(1) end
print("OK: " .. tostring(#expected) .. " kinds, all non-empty")
'
```

Expected output: `OK: 41 kinds, all non-empty`
If output starts with `MISSING:` or `EMPTY:`, fix the listed keys in `icons.lua` and re-run.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/libs/icons.lua
git commit -m "feat(nvim/cmp-icons): swap kinds to codicon glyphs + add Default

Replace heterogeneous nf-md/nf-cod glyphs in icons.kinds with a
consistent nf-cod-symbol_* codicon vocabulary for an Emacs lsp-mode
aesthetic. Add kinds.Default (symbol_misc) as a fallback for unknown
LSP kinds.

Spec: docs/superpowers/specs/2026-04-30-cmp-emacs-icons-design.md"
```

---

## Task 2: Add `Default` fallback in `cmp.lua`

**Files:**
- Modify: `nvim/lua/config/cores/cmp.lua:62`

- [ ] **Step 1: Read the current line**

Run: `sed -n '57,65p' nvim/lua/config/cores/cmp.lua`
Expected output:
```
    format = function(entry, item)
      local icons = require('config.libs.icons').kinds
      local kind = item.kind
      local kind_hl_group = ('CmpItemKind%s'):format(kind)

      item.kind = (' %s '):format(icons[kind])

      local source = entry.source.name
      item.menu = kind
```

- [ ] **Step 2: Replace the icon assignment line with fallback-aware version**

Use the Edit tool. Replace exactly:

```lua
      item.kind = (' %s '):format(icons[kind])
```

With:

```lua
      item.kind = (' %s '):format(icons[kind] or icons.Default)
```

(Single line change. Indentation: 6 spaces. No other lines in the file change.)

- [ ] **Step 3: Verify the file still parses**

Run: `nvim --headless -c 'luafile nvim/lua/config/cores/cmp.lua' -c 'qa' 2>&1 | head -20`
Expected: empty output (silent success). If you see Lua errors mentioning syntax or `cmp not found`, the latter is fine (cmp may not be loadable in headless mode without plugins) — what we're checking is that there's no syntax error. Treat as PASS unless the error message says `unexpected symbol`, `'<eof>' expected`, or similar parse error.

A stricter check that doesn't load cmp:

```bash
lua -e 'local f = loadfile("nvim/lua/config/cores/cmp.lua"); if f then print("PARSE OK") else print("PARSE FAIL") os.exit(1) end'
```
Expected: `PARSE OK`

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/cores/cmp.lua
git commit -m "feat(nvim/cmp): fall back to kinds.Default for unknown LSP kinds

Avoids rendering literal ' nil ' in the completion popup when an LSP
server returns a kind not in icons.kinds.

Spec: docs/superpowers/specs/2026-04-30-cmp-emacs-icons-design.md"
```

---

## Task 3: Visual verification in Neovim

This task has no commits — it's the human-eyes check that the popup renders the new glyphs correctly.

- [ ] **Step 1: Pick a file with rich LSP completions**

Choose any TypeScript or Lua file in the repo where LSP is active. For example:
```bash
nvim nvim/lua/config/cores/cmp.lua
```

- [ ] **Step 2: Trigger the completion popup**

In normal mode, navigate to a place where you can type. Enter insert mode, start typing a partial identifier (e.g. `vim.`), and wait for the popup. Or press `<C-Space>` to force-trigger completion.

- [ ] **Step 3: Confirm visual outcome**

Visually check:
- [ ] Variable entries show the codicon cube glyph (`symbol_variable`).
- [ ] Function/Method entries show the codicon parens-shape glyph (`symbol_method`).
- [ ] Keyword entries show the three-bar codicon (`symbol_keyword`).
- [ ] Module/Namespace entries show the hexagon-style glyph (`symbol_namespace`).
- [ ] Class entries show the clover/branch-shape glyph (`symbol_class`).
- [ ] No entry renders as a literal `nil`, blank, or `?`-tofu rectangle.

If any glyph renders as a tofu (`▯`), that codepoint isn't in the active Nerd Font and the codepoint table at the top of this plan needs correction for that kind. Look up the actual codepoint via `nf-cod-<name>` on the Nerd Fonts cheatsheet (`https://www.nerdfonts.com/cheat-sheet`) and fix `icons.kinds` for that one entry, then re-run Task 1 step 3 verification and amend or follow-up commit.

- [ ] **Step 4: Confirm fallback works (optional spot-check)**

In a Lua scratch buffer, run:
```vim
:lua print((' %s '):format(require('config.libs.icons').kinds['NotARealKind'] or require('config.libs.icons').kinds.Default))
```
Expected: prints ` <misc-glyph> ` (the codicon `symbol_misc`), not ` nil `.

---

## Self-Review Notes

**Spec coverage check:**
- Spec §1 (icon mapping): covered by Task 1 step 2's complete table.
- Spec §2 (non-LSP kinds preserved/remapped): covered (Codeium/Copilot/TabNine/Supermaven preserved verbatim; Control → symbol_misc; Collapsed → chevron_right).
- Spec §3 (trailing-space convention): every entry in Task 1's replacement block ends with `' '` before the closing quote.
- Spec §4 (fallback): covered by Task 1 (`Default` entry) + Task 2 (`or icons.Default`).
- Spec §5 (verification): Task 1 step 3 (Lua sanity script) + Task 3 step 3 (visual check).

**Type/name consistency check:**
- `icons.kinds.Default` is referenced consistently across Task 1 (defined), Task 2 (used in fallback), Task 3 step 4 (spot-checked).
- Indentation of the replacement block matches the surrounding file (2 spaces inside the outer return, 4 inside the kinds table). Verified against the current file shape in Task 1 step 1.

**Placeholder scan:** none.
