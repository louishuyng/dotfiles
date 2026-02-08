# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end

set --erase _asdf_shims

# FIX: set default key bindings fixing https://stackoverflow.com/a/41905020
set -U fish_key_bindings fish_default_key_bindings

set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

source ~/.dotfiles/terminals/fish/alias/init.fish
source ~/.dotfiles/terminals/fish/env/init.fish

starship init fish | source

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

eval "$(pyenv init --path)"

set fish_greeting ""

# Doom Emacs configuration
set -gx DOOMDIR "$HOME/.doom.d"

zoxide init fish | source

set -gx ATUIN_NOBIND true
atuin init fish | source

switcher init fish | source

# optionally use alias `s` instead of `kubeswitch` (add to config.fish)
function s --wraps switcher
    kubeswitch $argv
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

fish_add_path /Users/louishuyng/.spicetify

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/louishuyng/.lmstudio/bin
# End of LM Studio CLI section
export PATH="$HOME/.local/bin:$PATH"

# opencode
fish_add_path /Users/louishuyng/.opencode/bin

# fish_add_path /Users/louishuyng/.iximiuz/labctl/bin
# labctl completion fish | source

# >>> coursier install directory >>>
set -gx PATH "$PATH:/Users/louishuyng/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
