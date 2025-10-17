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
# For MacOS
./bootstrap/mac.sh

# For Arch Linux
./bootstrap/arch.sh
```

## Nix Setup
Installing nix package manager following the documentation [here](https://nixos.org/download.html)

```bash
ln -s ~/.dotfiles/nix ~/.config/nix # Create Symlink with nix config
ln -s ~/.dotfiles/home-manager ~/.config/home-manager # Create Symlink with home-manager config

nix-shell -p home-manager # Run new shell with home-manager package

home-manager switch # Apply the configuration
```

## Examples
- [Showcases](examples/showcases.md)
