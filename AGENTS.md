# AGENTS.md - Coding Agent Instructions

## Project Overview

This is a personal dotfiles repository managing development environment configuration for macOS.
Primary components: Neovim (Lua), Fish shell, Tmux, Ghostty/WezTerm terminals, Aerospace window
manager, SketchyBar, Karabiner, and Nix/Home Manager. There is no traditional build system,
test suite, or CI pipeline.

## Repository Structure

```
nvim/              Neovim config (Lua) - the largest and most actively edited component
  lua/plugins/     Plugin declarations (lazy.nvim spec tables)
  lua/config/      Plugin configuration (cores/, libs/, lsp/)
  lua/mappings/    Keybindings organized by domain (editor/, languages/, source_control/, utils/)
  lua/cmds/        Autocommands
  lua/options/     Vim options
  lua/ui/          Statusline, winbar, buffer UI, dashboard
  lua/utils/       Small utility modules
  lua/functions/   Custom Lua functions
terminals/         Shell and terminal emulator configs (fish/, tmux/, ghostty/, wezterm/, etc.)
suckless/          Window manager and desktop tool configs (aerospace, sketchybar, karabiner, yazi)
bootstrap/         OS setup scripts (mac.sh, arch.sh, debian.sh)
scripts/           Standalone utility scripts (shell)
config/            Git config, SSH config, docker-compose name mappings
home-manager/      Nix Home Manager flake (flake.nix, home.nix)
devops/            Docker compose files, Helm/Terraform configs
opencode/          OpenCode AI agent config
.doom.d/           Doom Emacs config (secondary editor)
```

## Build / Lint / Test Commands

There is no unified build or test system. Validation is done per-component:

### Neovim (Lua)
```bash
# Format all Lua files with StyLua (config: nvim/.stylua.toml)
stylua nvim/

# Check a single file
stylua --check nvim/lua/plugins/editor.lua

# Lint Lua (configured via .luarc.json at repo root)
# The luarc disables: different-requires, redefined-local, unused-local,
# cast-local-type, duplicate-index, undefined-global, deprecated, assign-type-mismatch
# Globals: vim, describe, it, before_each, after_each, _lazygit_toggle

# Open Neovim and verify no errors on startup
nvim --headless "+Lazy! sync" +qa

# Check health inside Neovim
# :checkhealth
```

### Shell Scripts
```bash
# Lint Fish scripts
fish --no-execute terminals/fish/config.fish

# Format Fish scripts (used by conform.nvim)
fish_indent -w terminals/fish/config.fish

# Lint Bash scripts with shellcheck
shellcheck bootstrap/mac.sh
shellcheck scripts/*.sh

# Format Bash with shfmt (used by conform.nvim)
shfmt -w bootstrap/mac.sh
```

### Nix / Home Manager
```bash
# Apply home-manager configuration
home-manager switch --flake ~/.dotfiles/home-manager

# Check flake
nix flake check ~/.dotfiles/home-manager
```

### SketchyBar
```bash
# Restart sketchybar after config changes
sketchybar --reload
# Or use the restart script
~/.dotfiles/suckless/mac_os/sketchybar/restart.sh
```

## Code Style Guidelines

### Lua (Neovim config) - PRIMARY LANGUAGE

**Formatter**: StyLua (config at `nvim/.stylua.toml`)
- Column width: 120
- Indent: 2 spaces
- Quote style: auto-prefer-single (use single quotes `'` by default)
- Call parentheses: Input style
- Line endings: Unix (LF)

**Imports and module loading**:
- Use `require 'module.path'` with single quotes (no parentheses for simple strings)
- Use `require('module')` with parentheses only when chaining or assigning inline
- Module paths use dots: `require 'config.cores.telescope'`
- LSP server requires use slashes: `require 'config/lsp/servers/lua'`
- Group requires logically with blank lines between sections
- Entry-point files (init.lua) just list requires, no logic

**Plugin declarations** (lua/plugins/*.lua):
- Return a table of plugin specs: `return { { 'author/plugin', ... }, ... }`
- Always specify lazy-loading: `event`, `cmd`, `ft`, or `keys`
- Use `config = function() ... end` for complex setup, `opts = {}` for simple
- Comment out unused plugins rather than deleting them (preserves history)

**Keymaps**:
- Standard opts pattern: `local opt = { silent = true, noremap = true }`
- Use `vim.keymap.set(mode, lhs, rhs, opts)` (not legacy vim.api.nvim_set_keymap)
- Add `desc` field to all keymaps for which-key discoverability
- Leader is Space, local leader is Comma

**Error handling**:
- Use `pcall` for optional module loading: `local ok, mod = pcall(require, 'module')`
- Early-return pattern on failure: `if not ok then return end`
- Guard against nil: check `if not client then return end`

**Naming conventions**:
- Files: lowercase with underscores (`git_blame_toggle.lua`, `vim_enter.lua`)
- Variables: snake_case (`local augroup`, `local mode_component`)
- Module directories: lowercase, no underscores (`config`, `mappings`, `plugins`)
- Constants/globals: `vim.g.*` for global editor state

**General patterns**:
- LSP config uses `vim.lsp.config()` + `vim.lsp.enable()` pattern (Neovim 0.11+)
- Formatters configured via conform.nvim (see `config/lsp/register_formatters.lua`)
- Linting via nvim-lint
- Testing via vim-test with snacks/wezterm strategy auto-detection
- Treesitter for syntax; disable built-in plugins for performance

### Fish Shell

- Aliases go in `terminals/fish/alias/` organized by domain (git.fish, devops.fish, etc.)
- Functions go in `terminals/fish/functions/` (one function per file, matching filename)
- Environment variables in `terminals/fish/env/` split by OS (mac.fish, linux.fish)
- Use `set -gx` for global exports, `set -U` for universal variables
- Format with `fish_indent`

### Bash (bootstrap/scripts)

- Start with `#! /bin/bash` and `set -e`
- Use helper functions for output: `info()`, `success()`, `fail()`
- Use `read -r -p` for interactive prompts
- Quote all variable expansions
- Format with `shfmt`, lint with `shellcheck`

### TOML / Config Files

- Aerospace config: `suckless/mac_os/aerospace/aerospace.toml`
- Ghostty config: `terminals/ghostty/config` (key = value format, no extension)
- Alacritty: `terminals/alacritty/alacritty.toml`
- StyLua: `nvim/.stylua.toml`
- Yazi: `suckless/yazi/*.toml`

### Nix

- Home Manager entry: `home-manager/home.nix`
- Flake: `home-manager/flake.nix`
- Target: aarch64-darwin (Apple Silicon Mac)
- Follow nixos-unstable channel

## Git Conventions

- Commit messages: lowercase, short, descriptive
- Prefixes used: `feat:`, `fix:`, `setup`, `update`, `add`, `build`
- Examples from history: `feat: update config`, `fix diagnostic api is deprecated`,
  `setup wezterm flow`, `build theme with lush`
- Git aliases defined in `config/.gitconfig` (co, br, ci, st, sync, lol, graph)
- Uses git-delta as pager, p4merge for diff/merge tool

## Symlink Architecture

Configs are symlinked from this repo to their expected system locations:
- `nvim/` -> `~/.config/nvim/`
- `terminals/fish/` -> `~/.config/fish/`
- `terminals/ghostty/` -> `~/.config/ghostty/`
- `suckless/mac_os/sketchybar/` -> `~/.config/sketchybar/`
- `home-manager/` -> `~/.config/home-manager/`
- GNU Stow is used for some symlinks (see `link_all_dotfiles()` in bootstrap/mac.sh)

## Key Tools and Versions

- Editor: Neovim (latest) with lazy.nvim plugin manager
- Shell: Fish (primary), Nushell (secondary)
- Terminal: Ghostty (primary), WezTerm, Kitty
- Window Manager: Aerospace (tiling)
- Menu Bar: SketchyBar
- Version Manager: mise (asdf-compatible)
- Font: JetBrains Mono Nerd Font
