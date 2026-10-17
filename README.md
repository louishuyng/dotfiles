## Description
A basic set of dotfiles to enhance my daily development workflow


## Terminal & Coding

My favorite editor is Neovim. and setup configured [Neovim](./nvim)

I prefer `fish` as main command line shell due to the beauty of the syntax see my configure [Fish](./terminals/fish)

Ghostty is quite popular terminal [Ghostty](./terminals/ghostty)

Tern defaults to Zed (`zed --wait`) in the macOS Fish/Zsh and Nushell configurations
when `TERM_PROGRAM=tern`; other terminals keep Neovim.
[Zed's configuration](./suckless/mac_os/zed/settings.json) enables Vim mode.
For Tern's shortcuts and external Git editor, keep [the Zed launcher](./terminals/tern/zed-project.sh)
at `~/.dotfiles/terminals/tern/zed-project.sh` and merge [these settings](./terminals/tern/settings.json)
into `~/Library/Application Support/Tern/settings.json` without replacing other preferences,
then run **Reload settings** from Tern's command palette.
Tern's built-in editor is unchanged.
`Ctrl+\` is explicitly passed through (`"ctrl+\\": []`), so it toggles
Neovim's file tree rather than Tern's Files panel. Tern's native Files shortcut
remains `Ctrl+Cmd+E`.

Keep plain Ctrl shortcuts for terminal programs and Cmd shortcuts or the
`Ctrl+A` prefix for Tern. Keybind overrides apply globally, not only in Neovim;
an empty action list passes that shortcut to the focused program.
`Ctrl+A` itself is reserved by the prefix setup; press it twice to send it to
the program.

`Ctrl+A`, then `g` opens Tern's native Git graph instead of the GitHub dashboard.
Opening a graph file in the external editor opens Zed at that file's repository
root, with the selected file active. Linked worktrees keep their own project root.

At a Fish or Zsh prompt in Tern, `Ctrl+N` focuses Neovim in the current tab.
If that tab has no running Neovim, it opens one in a right split using the
shell's current directory. Neovim in other tabs does not prevent a new split.
Other terminals retain the in-place `Ctrl+N` launch.

I love tmux when working with multiple projects [Tmux](./terminals/tmux)

## Window Manager

- Control all my windows with [Aerospace](./suckless/mac_os/aerospace) 
- Decorator menubar UI with [Sketchy Bar](./suckless/mac_os/sketchybar)
- Additional Key bindings with [Karabiner](./suckless/mac_os/karabiner)

## Installation

```bash
# For macOS: select tasks, review commands, then confirm
bash bootstrap/mac.sh

# For Arch Linux
bash bootstrap/arch.sh

# For Debian / Ubuntu
bash bootstrap/debian.sh
```

See the [bootstrap guide](bootstrap/README.md) for task options, previews,
configuration backups, and manual application steps. Preview a macOS setup:

```bash
bash bootstrap/mac.sh --tasks core,git,fish,nvim,tmux,ghostty,fonts --dry-run
```

## Nix Setup
Installing nix package manager following the documentation [here](https://nixos.org/download.html)

```bash
bash bootstrap/mac.sh --tasks nix --links-only # Review and link Nix configs

nix-shell -p home-manager # Run new shell with home-manager package

home-manager switch --flake ~/.dotfiles/home-manager # Apply the Apple Silicon Mac configuration
```

## Examples
- [Showcases](examples/showcases.md)
