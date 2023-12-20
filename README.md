
A basic set of dotfiles to enhance my daily development workflow 🧑‍🎨

## Flow with Terminal & Shell

I mostly using neovim as a main text editor. You can check the setup [here](./nvim)

Most people use zsh as their `shell`, but I prefer `fish` because it is simpler and easier to configure. 
I also love the syntax of fish. To see more my configure [here](./terminals/fish)

My main terminal is [alacritty](./terminals/alacritty)

When handling multiple terminal at the same time i prefer using  [Tmux](./terminals/tmux)

## Flow with Window Management

I use [yabai](./suckless/mac_os/yabai) as the main window management system and also setup a decorator menubar UI using [Sketchy Bar](./suckless/mac_os/sketchybar)

In addition, I have configured keybindings to improve my speed and control over Windows or applications.

Two main key binding tools are below:
- [Skhd](./suckless/mac_os/skhdrc)
- [Karabiner](./suckless/mac_os/karabiner)

## How i setup that?

Basically, I save all instructions for installing tools and plugins in the shell file below.
Simply run it, and it will be set up for you.

```bash
# For MacOS
./bootstrap/mac.sh

# For Arch Linux
./bootstrap/arch.sh
```

## Screenshots
<img width="1710" alt="image" src="https://github.com/louishuyng/dotfiles/assets/40130936/2ea0e3bd-2342-44b5-afb1-fcf101ca26a7">
