$env.config.show_banner = false

# Asdf setup
let shims_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )

# Environment variables
$env.config.edit_mode = 'vi'
$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"
$env.TERM = "xterm-256color"

# Path additions
# Homebrew's sbin
$env.PATH = ($env.PATH | split row (char esep) | append "/opt/homebrew/bin" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/sbin" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append "/opt/homebrew/sbin" | uniq)

# Qutebrowser
$env.PATH = ($env.PATH | split row (char esep) | append "/Applications/qutebrowser.app/Contents/MacOS" | uniq)

# Flutter
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/development/flutter/bin" | uniq)

# Android
$env.ANDROID_HOME = $"($env.HOME)/Library/Android/sdk"
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/Library/Android/sdk" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.ANDROID_HOME)/emulator" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.ANDROID_HOME)/tools" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.ANDROID_HOME)/tools/bin" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.ANDROID_HOME)/platform-tools" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.pub-cache/bin" | uniq)

# SQL
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/mysql/bin" | uniq)

# Python
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/opt/python/libexec/bin" | uniq)

# JAVA
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/libexec/java_home" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append "/opt/homebrew/opt/openjdk/bin" | uniq)
$env.CPPFLAGS = "-I/opt/homebrew/opt/openjdk/include"

# Golang
$env.GOROOT = ""
# Adjusted command substitution for Nu
$env.GOBIN = (go env GOBIN | str trim)
$env.GOPATH = $"($env.HOME)/development/golib"
$env.GO111MODULE = "on"
# Adjusted command substitution for Nu
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.GOPATH)/bin" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.GOROOT)/bin" | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append $env.GOBIN | uniq)
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/go/bin" | uniq)

# OPEN SSL
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/opt/openssl/bin" | uniq)

# Prompt Config
$env.STARSHIP_CONFIG = $"($env.HOME)/.dotfiles/terminals/starship/config.toml"

# Editor
$env.EDITOR = "nvim"
# Note: fzf_directory_opts would need to be handled differently in Nu
$env.GIT_EDITOR = "nvim"
$env.REACT_EDITOR = "nvim"

# Fzf
$env.FZF_COMPLETION_TRIGGER = "**"
$env.FZF_DEFAULT_COMMAND = "rg --files --hidden"
$env.FZF_DEFAULT_OPTS = "--layout reverse --preview=\"bat --color=always {}\" --preview-window=\"up,60%,border-bottom,+{2}+3/3,~3\""

# TLDR
$env.TLDR_OS = "osx"

$env.DISABLE_SPRING = true

# Yabai
$env.YABAI_CERT = "yabai-cert"

# Bat
$env.BAT_THEME = "TwoDark"

# Rust
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.cargo/bin" | uniq)

# Scripts
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.config/scripts" | uniq)

# GNU sed
$env.PATH = ($env.PATH | split row (char esep) | append "/usr/local/opt/gnu-sed/libexec/gnubin" | uniq)

# Emacs
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.emacs.d/bin" | uniq)

# MacPort
$env.PATH = ($env.PATH | split row (char esep) | append "/opt/local/bin" | uniq)

# Webstorm Path
$env.PATH = ($env.PATH | split row (char esep) | append "/Applications/WebStorm.app/Contents/MacOS" | uniq)

# Postgres Lib
$env.PATH = ($env.PATH | split row (char esep) | append "/opt/homebrew/opt/libpq/bin/pg_restore" | uniq)

# Wezterm
$env.PATH = ($env.PATH | split row (char esep) | append "/Applications/WezTerm.app/Contents/MacOS" | uniq)

# Vault
$env.VAULT_ADDR = "http://127.0.0.1:8200"

# Ghostty
$env.SNACKS_GHOSTTY = "true"
