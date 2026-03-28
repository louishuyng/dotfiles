# ── Completion (must be first) ────────────────────────────────────────────────
autoload -Uz compinit
compinit
# Bash-style completion support (needed for AWS CLI, etc.)
autoload -Uz bashcompinit
bashcompinit

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# ── Key bindings (emacs mode, matching fish defaults) ─────────────────────────
bindkey -e

# ── Bootstrap PATH (needed before anything else) ──────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/sbin:$PATH"

# ── Env, Aliases & Functions ──────────────────────────────────────────────────
source ~/.dotfiles/terminals/zsh/env/mac.zsh
source ~/.dotfiles/terminals/zsh/alias/init.zsh
source ~/.dotfiles/terminals/zsh/functions.zsh

# ── Core tools ────────────────────────────────────────────────────────────────
eval "$(mise activate zsh)"
eval "$(tv init zsh)"

# ── Prompt ────────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── AWS CLI autocompletion ────────────────────────────────────────────────────
complete -C aws_completer aws

# ── Python ────────────────────────────────────────────────────────────────────
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ── Zoxide ────────────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Atuin ─────────────────────────────────────────────────────────────────────
export ATUIN_NOBIND=true
eval "$(atuin init zsh)"

# ── Kubeswitch ────────────────────────────────────────────────────────────────
eval "$(switcher init zsh)"

# ── OrbStack ──────────────────────────────────────────────────────────────────
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ── UI enhancements (fish-like) ───────────────────────────────────────────────
# Autosuggestions
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (must be last)
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
