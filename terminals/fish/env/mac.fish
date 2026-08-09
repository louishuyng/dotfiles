# Environment variables
# Note: mise is activated in config.fish

# Appearance detection and theme sourcing live in the fish_prompt wrapper in
# config.fish, which re-checks on every prompt; doing it here too just paid for
# a second `defaults read` per shell.

# You may need to manually set your language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

if test -n "$TMUX"
    set -gx TERM tmux-256color
else
    set -gx TERM xterm-256color
end

#Homebrew's sbin
fish_add_path /opt/homebrew/bin
fish_add_path /usr/local/sbin
fish_add_path /opt/homebrew/sbin
set -gx PANDOC_PATH /opt/homebrew/bin/pandoc
#
# #Qutebrowser
fish_add_path /Applications/qutebrowser.app/Contents/MacOS
#
# #Fluter
fish_add_path $HOME/development/flutter/bin
#
# #Android
set -gx ANDROID_HOME ~/Library/Android/sdk
fish_add_path $HOME/Library/Android/sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $HOME/.pub-cache/bin
#
# #SQL
fish_add_path /usr/local/mysql/bin
#
# #Python
fish_add_path /usr/local/opt/python/libexec/bin
#
# #JAVA
fish_add_path /usr/libexec/java_home
fish_add_path /opt/homebrew/opt/openjdk/bin
set -gx CPPFLAGS -I/opt/homebrew/opt/openjdk/include
#
# #Golang
set -gx GOPATH $HOME/development/golib
set -gx GO111MODULE on
fish_add_path $GOPATH/bin

# go is a mise shim, so `go env GOROOT/GOBIN` pays the shim cost twice (~120ms) to
# report the mise install dir. Ask mise once instead — and cache that too, because
# `mise where go` is still a ~26ms subprocess on every shell.
#
# Keyed on the mise binary and the global config, the two things that change which
# path comes back. A per-directory .tool-versions is deliberately not a key: this
# runs once at startup, so GOROOT was already the global answer regardless of where
# the shell later cds to.
if command -q mise
    set -l _stamp (builtin path mtime (command -v mise) ~/.config/mise/config.toml 2>/dev/null | string join -)
    set -l _cache $__fish_cache_dir/mise-where-go-$_stamp

    if not test -s $_cache
        command mkdir -p $__fish_cache_dir
        # via `set`, which is exempt from fish's no-matches-for-wildcard error
        set -l _stale $__fish_cache_dir/mise-where-go-*
        test (count $_stale) -gt 0; and command rm -f $_stale
        mise where go >$_cache 2>/dev/null; or command rm -f $_cache
    end

    set -l _go_prefix
    test -s $_cache; and read -l _go_prefix <$_cache

    if test -n "$_go_prefix"
        set -gx GOV $_go_prefix
        set -gx GOROOT $_go_prefix
        set -gx GOBIN $_go_prefix/bin
        fish_add_path $GOROOT/bin
        fish_add_path $GOBIN
    end
end

#
# # OPEN SSL
fish_add_path /usr/local/opt/openssl/bin
#

# # Editor
set -gx EDITOR nvim
set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
set -gx GIT_EDITOR nvim
set -gx REACT_EDITOR nvim

# # Fzf
set -gx FZF_COMPLETION_TRIGGER '**'
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden'
set -gx FZF_DEFAULT_OPTS '--layout reverse --preview="bat --color=always {}" --preview-window="up,60%,border-bottom,+{2}+3/3,~3"'

# #TLDR
set -gx TLDR_OS osx
#
set -gx DISABLE_SPRING true

# # Yabai
set -gx YABAI_CERT yabai-cert
#
# # Bat
set -gx BAT_THEME TwoDark

# #Rust
fish_add_path $HOME/.cargo/bin
#
# #GO
fish_add_path /usr/local/go/bin

# # ROR
set -gx BUNDLE_EDITOR nvim
set -e GEM_HOME

# #Scripts
fish_add_path $HOME/.config/scripts

# # GNU sed
fish_add_path /usr/local/opt/gnu-sed/libexec/gnubin

# Emacs
fish_add_path ~/.emacs.d/bin/
fish_add_path ~/.config/emacs/bin

# MacPort
fish_add_path /opt/local/bin

# Webstorm Path
fish_add_path /Applications/WebStorm.app/Contents/MacOS

# Postgres Lib
fish_add_path /opt/homebrew/opt/libpq/bin/pg_restore

# Wezterm
fish_add_path /Applications/WezTerm.app/Contents/MacOS

# Vault
set -gx VAULT_ADDR http://127.0.0.1:8200

# Ghostty
fish_add_path SNACKS_GHOSTTY=true

# Terraform
set -gx TFENV_ARCH arm64

# Duck DB
fish_add_path ~/.duckdb/cli/latest

# K8s etcd
fish_add_path ~/LX14/repository/github.com/louishuyng/kubernetes/third_party/etcd

# `read` is a builtin; `(cat file)` here forked three times.
if test -r ~/.github_token
    read -l _gh_token <~/.github_token
    set -gx GITHUB_TOKEN $_gh_token
    set -gx NODE_AUTH_TOKEN $_gh_token
end
if test -r ~/.knock_service_token
    read -l _knock_token <~/.knock_service_token
    set -gx KNOCK_SERVICE_TOKEN $_knock_token
end

# Lua Binaries
fish_add_path ~/.luarocks/bin/

# Tudo
set -gx TODO_DIR ~/LX14/notes/tuxedo/
