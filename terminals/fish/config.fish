if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

source /usr/local/opt/asdf/libexec/asdf.fish
source ~/.dotfiles/terminals/fish/alias/init.fish
source ~/.dotfiles/terminals/fish/env/init.fish
