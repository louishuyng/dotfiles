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

set fish_color_command normal
set fish_color_comment red
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end green
set fish_color_error brred
set fish_color_escape brcyan
set fish_color_history_current --bold
set fish_color_host normal
set fish_color_host_remote yellow
set fish_color_keyword normal
set fish_color_operator brcyan
set fish_color_option cyan
set fish_color_param cyan
set fish_color_quote yellow
set fish_color_redirection cyan --bold
set fish_color_search_match white --background=brblack --bold
set fish_color_selection white --background=brblack --bold
set fish_color_status red
set fish_color_user brgreen
set fish_color_valid_path --underline
set fish_pager_color_completion normal
set fish_pager_color_description yellow -i
set fish_pager_color_prefix normal --bold --underline
set fish_pager_color_progress brwhite --background=cyan --bold
set fish_pager_color_selected_background -r

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

eval "$(pyenv init --path)"

set fish_greeting ""

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
