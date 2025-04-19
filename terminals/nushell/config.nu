# Functions
source ~/.dotfiles/terminals/nushell/functions.nu

# Aliases
source ~/.dotfiles/terminals/nushell/aliases.nu

# Key Bindings
source ~/.dotfiles/terminals/nushell/key-bindings.nu

# Completions
source ~/.dotfiles/terminals/nushell/completer.nu

# Starship setup
$env.STARSHIP_SHELL = "nushell"

# the state of the prompt
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = ""
$env.config.render_right_prompt_on_last_line = true

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Atuin setup
source ~/.local/share/atuin/init.nu

# Zoxide setup
source ~/.zoxide.nu
