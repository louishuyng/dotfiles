# Emacs Keybindings — Match Nvim/Zed Experience

**Date:** 2026-04-29
**Status:** Design

## Goal

Rebuild a Doom Emacs configuration whose keybindings mirror the user's existing
Neovim setup so that switching editors does not require relearning muscle
memory. The user already had a `.doom.d/` configuration; it has been deleted
from the working tree and is being rebuilt cleanly.

## Background

- Neovim is the user's primary editor. Mappings live under
  `nvim/lua/mappings/**/*.lua` plus inline `vim.keymap.set` calls in
  `nvim/lua/config/**/*.lua`.
- Leader convention: `mapleader = ' '` (space), `maplocalleader = ','`
  (`nvim/init.lua:19-20`). Doom Emacs uses the same defaults out of the box, so
  no leader remapping is required.
- The previous `.doom.d/` (still in `HEAD` as a deletion) had eight keybinding
  modules: `+general`, `+lsp`, `+git`, `+tree`, `+workspace`, `+test`, `+term`,
  `+ai`. We will redo this set, expanded to cover the additional nvim
  categories (utils, languages, devops, dap).
- Goal is full parity, not a subset.

## Deliverables

Two artifacts, both committed to the dotfiles repo:

### 1. `docs/key-bindings-nvim.md`

A canonical catalog of the user's nvim keybindings. Source of truth for the
Emacs work and a standalone reference. Organized by the same categories as
`nvim/lua/mappings/`:

- editor (general, buffer, tree, telescope, test, dap, code_runner, ctrlf,
  todocomment, undotree)
- source_control (gitsigns, telescope_git, conflict)
- languages (spec)
- utils (fold, search, quickfix, operator_pending)
- devops (network)

Each entry follows this format:

```markdown
- `n <leader>w` — Save buffer (`:silent w!`) — `mappings/editor/general.lua:58`
  - Doom: `(map! :leader :n "w" #'save-buffer)`
  - Status: ✅
```

Three pieces of information per entry:

1. **nvim binding** — mode, key sequence, behavior, source file:line.
2. **Doom equivalent** — the elisp form that produces the same effect.
3. **Status flag** — ✅ exact parity, ⚠️ partial parity (with prose note),
   ❌ not feasible (with reason).

A header at the top of the file documents the leader convention and the
plugin-equivalence map (see below).

### 2. `.doom.d/` (rebuilt)

```
.doom.d/
├── init.el                  # enabled Doom modules
├── packages.el              # extra packages (copilot, etc.)
├── config.el                # UI / personal config
├── custom.el                # auto-generated
└── keybindings/
    ├── +init.el             # loader: (load! "+general") (load! "+editor") ...
    ├── +general.el          # C-hjkl, ,s/,v splits, save/quit, motions
    ├── +editor.el           # buffer, code_runner, todocomment, undotree, ctrlf
    ├── +tree.el             # treemacs (file tree)
    ├── +telescope.el        # vertico/consult (find file, grep, etc.)
    ├── +lsp.el              # LSP actions
    ├── +git.el              # magit + git-gutter (gitsigns parity)
    ├── +test.el             # test runner
    ├── +dap.el              # debugger
    ├── +workspace.el        # persp-mode / workspaces
    ├── +term.el             # vterm
    ├── +ai.el               # copilot
    ├── +utils.el            # fold, search, quickfix, operator-pending
    ├── +languages.el        # spec/language-specific
    └── +devops.el           # network etc.
```

The `keybindings/` folder mirrors `nvim/lua/mappings/` categories so
cross-referencing is direct.

## Doom modules (`init.el`)

Enable only what is needed to match nvim's plugin set:

```elisp
:completion   vertico company
:ui           doom doom-dashboard hl-todo hydra modeline ophints
              (popup +defaults) treemacs (vc-gutter +pretty)
              vi-tilde-fringe workspaces
:editor       (evil +everywhere) file-templates fold (format +onsave)
              multiple-cursors snippets word-wrap
:emacs        dired electric ibuffer undo vc
:term         vterm
:checkers     syntax (spell +flyspell)
:tools        (eval +overlay) lookup magit lsp
              (debugger +lsp) tree-sitter
:lang         emacs-lisp markdown (org +pretty) sh
              (typescript +lsp) ruby python rust go
```

## Plugin equivalence map

Tracked in the catalog header. Bridges that need calling out:

| nvim plugin               | Doom Emacs equivalent                  | Parity                  |
|---------------------------|----------------------------------------|-------------------------|
| telescope / snacks picker | vertico + consult + embark             | ✅                      |
| neo-tree / nvim-tree      | treemacs                               | ✅                      |
| flash.nvim                | avy                                    | ⚠️ similar, different feel |
| gitsigns.nvim             | git-gutter (vc-gutter +pretty)         | ✅                      |
| neogit / fugitive         | magit                                  | ✅ better               |
| neotest                   | doom test or shell-runner via +test.el | ⚠️                      |
| nvim-dap                  | dap-mode (`:tools (debugger +lsp)`)    | ✅                      |
| toggleterm                | vterm                                  | ✅                      |
| copilot.lua               | copilot.el                             | ✅                      |
| trouble.nvim              | flycheck list / consult-flymake        | ✅                      |
| undotree                  | vundo                                  | ✅                      |
| nvim-spectre              | wgrep + consult-grep                   | ⚠️ different            |
| conflict-marker           | smerge-mode                            | ✅                      |

`⚠️` entries get prose notes in the catalog explaining the divergence so
muscle memory adjusts deliberately.

## Build order

1. **Catalog first.** Scan `nvim/lua/mappings/**/*.lua` and
   `nvim/lua/config/**/*.lua` for `vim.keymap.set` and `which_key` group
   definitions. Produce `docs/key-bindings-nvim.md` with every entry, status
   defaulting to "todo". No Emacs changes yet.
2. **Scaffold `.doom.d/`.** Write `init.el`, `packages.el`, `config.el`, and
   an empty `keybindings/+init.el` loader. Run `doom sync`, confirm Emacs
   starts.
3. **Mirror by category, top to bottom of the catalog.** Order: editor/general
   (the muscle-memory bedrock), editor/buffer, tree, telescope, lsp, git, test,
   dap, workspace, term, ai, utils, languages, devops. Each entry: write the
   `map!` form, update catalog status, move on.
4. **Per-category sanity check.** After each module, `doom sync`, restart
   Emacs, open a relevant buffer, exercise 2-3 bindings.

## Verification

- Walk the catalog top-to-bottom; every ✅ entry must trigger the documented
  command in Emacs. Any ⚠️ partial entry has a prose note explaining the
  divergence.
- No automated test suite — keybindings are manual UI behavior. Verification
  is "I press the keys, the right thing happens."
- Catalog is the test plan: when every entry has a status that is not "todo",
  the work is done.

## Out of scope

- Performance tuning (`gc-cons-threshold`, native-comp tweaks beyond Doom
  defaults).
- Org-mode / writing workflows.
- Theme customization beyond `doom-tokyo-night` to match nvim.
- Dired / file management workflows beyond what nvim has.

## Open questions

None at design time. Plugin-parity edge cases (flash vs avy, neotest vs
shell-runner) get resolved during implementation by adding prose notes to the
catalog rather than blocking the design.
