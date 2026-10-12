## Description
A basic set of dotfiles to enhance my daily development workflow


## Terminal & Coding

My favorite editor is Neovim. and setup configured [Neovim](./nvim)

I prefer `fish` as main command line shell due to the beauty of the syntax see my configure [Fish](./terminals/fish)

Ghostty is quite popular terminal [Ghostty](./terminals/ghostty)

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
