source ~/.dotfiles/terminals/fish/env/credential.fish
source ~/.dotfiles/terminals/fish/env/generic.fish
source ~/.dotfiles/terminals/fish/env/nnn.fish

fish_add_path ~/.dotfiles/scripts
fish_add_path ~/.bun/bin

switch (uname)
    case Linux
        source ~/.dotfiles/terminals/fish/env/linux.fish
    case Darwin
        source ~/.dotfiles/terminals/fish/env/mac.fish
end
