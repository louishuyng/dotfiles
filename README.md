# Dotfiles / terminal to desktop

My daily development setup: Neovim, Fish, and a tiled macOS desktop.

[![Neovim in Ghostty with the macOS menu bar](https://github.com/user-attachments/assets/b42357d5-1d7f-4966-8aec-333c9be1d0c0)](examples/showcases.md)

[More showcases →](examples/showcases.md)

## The setup

| Terminal & coding                       | macOS desktop                                        |
| --------------------------------------- | ---------------------------------------------------- |
| [Neovim](nvim) · editor                 | [Aerospace](suckless/mac_os/aerospace) · windows     |
| [Fish](terminals/fish) · shell          | [SketchyBar](suckless/mac_os/sketchybar) · menu bar  |
| [Ghostty](terminals/ghostty) · terminal | [Karabiner](suckless/mac_os/karabiner) · keybindings |
| [Tmux](terminals/tmux) · sessions       |                                                      |

## Set up

Configs retain personal paths and Git identity. Review them before applying.
From the repo root, select tasks, review commands, then confirm:

```bash
# macOS
bash bootstrap/mac.sh

# Arch Linux
bash bootstrap/arch.sh

# Debian / Ubuntu
bash bootstrap/debian.sh
```

Preview macOS without changing files:

```bash
bash bootstrap/mac.sh --tasks core,git,fish,nvim,tmux,ghostty,fonts --dry-run
```

See the [bootstrap guide](bootstrap/README.md) for options, backups, platform
limits, and manual steps.

<details>
<summary>Optional: Nix / Home Manager</summary>

The [Home Manager flake](home-manager/flake.nix) targets Apple Silicon Macs
(`aarch64-darwin`). [Install Nix](https://nixos.org/download.html), then:

```bash
bash bootstrap/mac.sh --tasks nix --links-only
nix-shell -p home-manager
home-manager switch --flake ~/.dotfiles/home-manager
```

</details>
