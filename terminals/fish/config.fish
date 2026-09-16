__init_cached mise activate fish
__init_cached tv init fish

# FIX: set default key bindings fixing https://stackoverflow.com/a/41905020
# Global, not universal: fish 4.3 moved this variable's default scope, and a `set -U`
# here fought the `set --erase --universal` in fish's own migration conf.d — every
# shell rewrote fish_variables and re-fired the fish_key_bindings VARIABLE SET
# handlers. That migration file is deleted; this is the scope fish now recommends.
set -g fish_key_bindings fish_default_key_bindings

set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

source ~/.dotfiles/terminals/fish/alias/init.fish
source ~/.dotfiles/terminals/fish/env/init.fish

# --print-full-init: plain `starship init fish` only emits a stub that shells out to
# this again, so caching the stub would still pay for the second call.
__init_cached starship init fish --print-full-init

# Wrap starship's fish_prompt to auto-detect macOS appearance on each prompt
functions -c fish_prompt __starship_fish_prompt
function fish_prompt
    set -l _plist ~/Library/Preferences/.GlobalPreferences.plist

    # The appearance read below forks a process costing ~11.7ms versus ~0.07ms for
    # a bare mtime stat, and this function runs on every prompt render. Gate the
    # fork behind the plist's mtime so it only fires when the appearance actually
    # changed.
    # Caveat: cfprefsd coalesces writes, so the mtime can lag the real toggle by a
    # few seconds — the theme catches up on the next prompt after the write lands.
    # path mtime needs fish 3.5+; fall back to reading live rather than guessing.
    set -l _mtime (builtin path mtime $_plist 2>/dev/null)
    if test -n "$_mtime"; and test "$_mtime" = "$_cached_appearance_mtime"
        __starship_fish_prompt
        return
    end
    set -g _cached_appearance_mtime $_mtime

    set -l _appearance (/usr/libexec/PlistBuddy -c "Print AppleInterfaceStyle" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
    if test -z "$_appearance"
        set _appearance Light
    end
    if test "$_appearance" != "$_cached_appearance"
        set -g _cached_appearance $_appearance
        if test "$_appearance" = Dark
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

__init_cached zoxide init fish
complete -c z -f -a "(zoxide query -l 2>/dev/null)" -d "zoxide dir"
complete -c zi -f -a "(zoxide query -l 2>/dev/null)" -d "zoxide dir"

set -gx ATUIN_NOBIND true
__init_cached atuin init fish

__init_cached switcher init fish

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

# opencode
fish_add_path /Users/louishuyng/.opencode/bin

# fish_add_path /Users/louishuyng/.iximiuz/labctl/bin
# labctl completion fish | source

# >>> coursier install directory >>>
set -gx PATH "$PATH:/Users/louishuyng/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<

# herdr is the outer multiplexer for interactive terminals. Guards: already inside
# a herdr pane, inside tmux, or remote (herdr --remote handles that). exec, so
# quitting herdr closes the window instead of leaving a parent shell.
#
# This stays at the bottom. Hoisting it above the prompt/plugin init to skip that
# work measured 5.7ms of a 122ms startup — the cost is front-loaded in conf.d and
# mise activation, both of which run before any line of this file.
# if status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
#     exec herdr
# end
