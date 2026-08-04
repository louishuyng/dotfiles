mise activate fish | source
tv init fish | source

# FIX: set default key bindings fixing https://stackoverflow.com/a/41905020
set -U fish_key_bindings fish_default_key_bindings

set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

source ~/.dotfiles/terminals/fish/alias/init.fish
source ~/.dotfiles/terminals/fish/env/init.fish

starship init fish | source

# Wrap starship's fish_prompt to auto-detect macOS appearance on each prompt
functions -c fish_prompt __starship_fish_prompt
function fish_prompt
    set -l _appearance (/usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
    if test -z "$_appearance"
        set _appearance Light
    end
    if test "$_appearance" != "$_cached_appearance"
        set -g _cached_appearance $_appearance
        if test "$_appearance" = "Dark"
            source ~/.dotfiles/terminals/fish/themes/catppuccin-mocha.fish
            set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/config.toml
        else
            source ~/.dotfiles/terminals/fish/themes/catppuccin-latte.fish
            set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/catppuccin-latte.toml
        end
    end
    __starship_fish_prompt
end

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

set fish_greeting ""

# Doom Emacs configuration
set -gx DOOMDIR "$HOME/.doom.d"

# Obsidian vault root, shared by the tmux note bindings (C-a n / C-a N)
set -gx NOTES_DIR "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Louis"

zoxide init fish | source
complete -c z -f -a "(zoxide query -l 2>/dev/null)" -d "zoxide dir"
complete -c zi -f -a "(zoxide query -l 2>/dev/null)" -d "zoxide dir"

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

# herdr is the outer multiplexer for interactive terminals. Guards: already
# inside a herdr pane, inside tmux, or remote (herdr --remote handles that).
# exec, so quitting herdr closes the window instead of leaving a parent shell.
if status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
    exec herdr
end
