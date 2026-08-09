source ~/.dotfiles/terminals/fish/env/credential.fish
source ~/.dotfiles/terminals/fish/env/generic.fish
source ~/.dotfiles/terminals/fish/env/nnn.fish

fish_add_path ~/.dotfiles/scripts
fish_add_path ~/.bun/bin
# herdr lives here, and config.fish resolves it before the rest of its init runs
fish_add_path ~/.local/bin

# A stat, not the ~6ms fork `uname` costs on this path. The plist is the marker
# Apple's own scripts use for "this is macOS".
if test -e /System/Library/CoreServices/SystemVersion.plist
    source ~/.dotfiles/terminals/fish/env/mac.fish
else
    source ~/.dotfiles/terminals/fish/env/linux.fish
end
