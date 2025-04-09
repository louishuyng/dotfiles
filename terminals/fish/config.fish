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

set -gx ATUIN_NOBIND "true"
atuin init fish | source

switcher init fish | source

# optionally use alias `s` instead of `kubeswitch` (add to config.fish)
function s --wraps switcher
        kubeswitch $argv;
end

# opam configuration
source /Users/louishuyng/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
switcher init fish | source

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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Added by Windsurf
fish_add_path /Users/louishuyng/.codeium/windsurf/bin

fish_add_path /Users/louishuyng/.spicetify
