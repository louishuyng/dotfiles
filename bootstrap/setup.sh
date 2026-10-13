#! /bin/bash
set -Ee -o pipefail

repo_root=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
platform=${1:-}
[[ $# -gt 0 ]] && shift
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
cache_dir=${XDG_CACHE_HOME:-"$HOME/.cache"}/dotfiles-bootstrap
backup_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/dotfiles-bootstrap/backups/$(date +%Y%m%d-%H%M%S)-$$
dry_run=false
yes=false
backup=false
plain=false
links_only=false
requested=
list=false
current_task=preflight
conflicts=0
manager_ready=false
tasks=()
labels=()
selected=()
export PATH="$HOME/.local/bin:$PATH"

info() { printf '  [INFO] %s\n' "$*"; }
success() { printf '  [OK] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*" >&2; exit 1; }

on_error() {
  local status=$?
  printf '\n  [FAIL] %s failed (exit %s). Completed tasks remain applied.\n' "$current_task" "$status" >&2
  printf '  Fix the error above, then retry: bash %q --tasks %q' "$repo_root/bootstrap/$platform.sh" "$current_task" >&2
  $backup && printf ' --backup' >&2
  $links_only && printf ' --links-only' >&2
  printf '\n' >&2
  exit "$status"
}
trap on_error ERR
trap 'printf "\n  [CANCELLED] Setup stopped; completed tasks remain applied.\n" >&2; exit 130' INT TERM

usage() {
  cat <<EOF
Usage: bash bootstrap/$platform.sh [options]

Choose tasks, review the plan, then apply it. Gum is optional.

  --tasks ID,ID   Select tasks without the menu (see --list)
  --list         Show tasks available for this platform
  --dry-run      Print commands and conflicts; change nothing
  --links-only   Link selected configs without installing packages/plugins
  --backup       Preserve conflicting configs in a dated backup, then link
  --yes          Apply the reviewed plan without a confirmation prompt
  --plain        Use numbered prompts instead of Gum; respect NO_COLOR
  --help         Show this help

Examples:
  bash bootstrap/$platform.sh
  bash bootstrap/$platform.sh --tasks core,git,fish,nvim,tmux --dry-run
  bash bootstrap/$platform.sh --tasks git,ai --links-only --backup
EOF
}

case "$platform" in mac|arch|debian) ;; *) fail 'Use mac.sh, arch.sh, or debian.sh.' ;; esac
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tasks)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail '--tasks needs comma-separated task IDs.'
      [[ -z "$requested" ]] || fail 'Pass --tasks only once.'
      requested=$2; shift ;;
    --dry-run) dry_run=true ;;
    --links-only) links_only=true ;;
    --backup) backup=true ;;
    --yes) yes=true ;;
    --plain) plain=true ;;
    --help|-h) usage; exit 0 ;;
    --list) list=true ;;
    *) fail "Unknown option: $1 (see --help)." ;;
  esac
  shift
done

add_task() { tasks+=("$1"); labels+=("$1 | $2"); }
add_task core 'Essential CLI / Git + search + previews + navigation'
add_task git 'Git config + GitHub CLI + delta + gh-dash'
add_task fish 'Fish + Starship + Fisher plugins (Atuin on macOS/Arch)'
add_task nvim 'Neovim (config requires 0.12+) + build tools'
add_task tmux 'Tmux + TPM + session config'
add_task kitty 'Kitty terminal + config'
add_task emacs 'Emacs + Doom config (Doom install is manual)'
add_task nnn 'nnn file manager + plugins'
add_task qutebrowser 'Qutebrowser + config'
add_task runtimes 'mise version manager (choose language versions later)'
add_task ai 'OpenCode + Claude config/skills links only'
add_task nix 'Nix/Home Manager config links only'
if [[ "$platform" != debian ]]; then
  add_task cli 'Extra CLI tools + Gum + Television + lint/format tools'
  add_task ghostty 'Ghostty terminal + config'
  add_task wezterm 'WezTerm terminal + config'
  add_task nushell 'Nushell + Carapace + config'
  add_task fonts 'JetBrains Mono Nerd Font'
  add_task yazi 'Yazi file manager + previews + config'
  add_task devops 'Docker + Kubernetes + Terraform tools'
fi
if [[ "$platform" == mac ]]; then
  add_task agent_hub 'Agent Hub web dashboard + background login service (requires Node 24 and Portless)'
  add_task zsh 'Alternative Zsh config + shell tools'
  add_task rio 'Rio terminal + config'
  add_task desktop 'Aerospace + SketchyBar/Lua + Borders + fonts'
  add_task karabiner 'Karabiner Elements + config'
  add_task editors 'Cursor + Zed + config + VSCodeVim'
  add_task extras 'Marta + Mailspring + Superfile + configs'
  add_task security 'Nmap + VPN tools (opt-in; ZAP install is manual)'
  add_task macos 'Preferences / keyboard + trackpad + Finder + screenshots'
fi

if $list; then printf '%s\n' "${labels[@]}"; exit 0; fi
for directory in "$HOME" "$config_dir" "$cache_dir" "$backup_dir"; do
  [[ "$directory" == /* ]] || fail "Home and XDG directories must be absolute: $directory"
done

use_gum() { ! $plain && [[ -t 0 && -t 1 && "${TERM:-dumb}" != dumb && -z "${NO_COLOR+x}" ]] && command -v gum >/dev/null; }
heading() {
  if use_gum; then
    gum style --border rounded --padding '1 2' --border-foreground 6 "$1"
  else
    printf '\n  %s\n\n' "$1"
  fi
}
confirm() {
  local answer
  if use_gum; then gum confirm "$1"; else
    read -r -p "  $1 [y/N] " answer || return 1
    [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]
  fi
}
select_tasks() {
  local choice i number
  [[ -t 0 && -t 1 ]] || fail 'No terminal: pass --tasks ID,ID and --dry-run or --yes.'
  heading "DOTFILES / $platform"
  info '1. Select  /  2. Review  /  3. Apply'
  if use_gum; then
    choice=$(gum choose --no-limit --height 12 --header 'Space: toggle  Enter: review  Ctrl+C: cancel' \
      --selected "${labels[0]},${labels[1]},${labels[2]},${labels[3]},${labels[4]}" "${labels[@]}") || exit 130
    [[ -n "$choice" ]] || { info 'No tasks selected.'; exit 0; }
    while IFS= read -r number; do selected+=("${number%% | *}"); done <<< "$choice"
  else
    for ((i=0; i<${#tasks[@]}; i++)); do printf '  %2d. %s\n' "$((i+1))" "${labels[i]}"; done
    printf '\n  Enter numbers separated by spaces (recommended: 1 2 3 4 5).\n'
    read -r -p '  Selection (empty cancels): ' choice || exit 130
    [[ -n "$choice" ]] || exit 0
    for number in $choice; do
      [[ "$number" =~ ^[1-9][0-9]?$ ]] || fail "Invalid selection: $number"
      ((number <= ${#tasks[@]})) || fail "Invalid selection: $number"
      selected+=("${tasks[number-1]}")
    done
  fi
}

if [[ -n "$requested" ]]; then
  task_pattern='^[a-z][a-z0-9_]*(,[a-z][a-z0-9_]*)*$'
  [[ "$requested" =~ $task_pattern ]] || fail '--tasks needs comma-separated task IDs without whitespace or empty IDs.'
  IFS=, read -r -a selected <<< "$requested"
else
  $yes && fail '--yes requires explicit --tasks.'
  select_tasks
fi
for choice in "${selected[@]}"; do
  found=false
  for task in "${tasks[@]}"; do [[ "$task" != "$choice" ]] || found=true; done
  $found || fail "Unknown or unsupported $platform task: $choice (see --list)."
done
# Run once in dependency order, regardless of selection order or duplicate IDs.
ordered=()
for task in "${tasks[@]}"; do
  for choice in "${selected[@]}"; do
    if [[ "$task" == "$choice" ]]; then ordered+=("$task"); break; fi
  done
done
selected=("${ordered[@]}")

run() {
  printf '    $'; printf ' %q' "$@"; printf '\n'
  $dry_run || "$@"
}
ensure_manager() {
  $manager_ready && return 0
  manager_ready=true
  if [[ "$platform" == mac ]]; then
    if ! command -v brew >/dev/null; then
      if [[ -x /opt/homebrew/bin/brew ]]; then export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      elif [[ -x /usr/local/bin/brew ]]; then export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
      else
        run /bin/bash -c 'installer=$(mktemp); trap '\''rm -f "$installer"'\'' EXIT; curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer" && /bin/bash "$installer"'
        if ! $dry_run; then
          if [[ -x /opt/homebrew/bin/brew ]]; then export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
          else export PATH="/usr/local/bin:/usr/local/sbin:$PATH"; fi
        fi
      fi
    fi
  elif [[ "$platform" == debian ]]; then run sudo apt-get update
  fi
}
packages() {
  $links_only && return 0
  ensure_manager
  case "$platform" in
    mac) run brew install "$@" ;;
    arch) run sudo pacman -S --needed "$@" ;;
    debian) run sudo apt-get install "$@" ;;
  esac
}
casks() { $links_only || { ensure_manager; run brew install --cask "$@"; }; }
install_mise() {
  $links_only && return 0
  if [[ "$platform" == debian ]]; then
    if ! command -v mise >/dev/null; then
      run /bin/bash -c 'installer=$(mktemp); trap '\''rm -f "$installer"'\'' EXIT; curl -fsSL https://mise.run -o "$installer" && sh "$installer"'
    fi
  else packages mise; fi
}

link_file() {
  local source=$1 target=$2 saved=
  if [[ ! -e "$source" ]]; then
    if ! $dry_run || [[ "$source" == "$repo_root/"* || "$source" == "$repo_root" ]]; then fail "Missing config source: $source"; fi
  fi
  if [[ "$source" -ef "$target" ]]; then info "Already linked: $target"; return; fi
  [[ "$source" != "$target/"* ]] || fail "Refusing to replace a directory containing the source checkout: $target"
  if [[ -e "$target" || -L "$target" ]]; then
    conflicts=$((conflicts+1))
    saved="$backup_dir/${target#"$HOME"/}"
    if $dry_run; then
      info "Conflict: $target (requires --backup)"
      if $backup; then run mkdir -p "$(dirname "$saved")"; run mv "$target" "$saved"; fi
    else
      $backup || fail "Config exists: $target. Review with --dry-run; use --backup to preserve it."
      run mkdir -p "$(dirname "$saved")"
      run mv "$target" "$saved"
    fi
  fi
  run mkdir -p "$(dirname "$target")"
  if ! run ln -s "$source" "$target"; then
    [[ -z "$saved" ]] || mv "$saved" "$target"
    fail "Could not link $target; its previous config was restored."
  fi
}
config() { link_file "$repo_root/$1" "$config_dir/$2"; }
clone_repo() {
  local url=$1 target=$2
  if [[ -d "$target/.git" ]]; then info "Checkout exists: $target"; return; fi
  [[ ! -e "$target" && ! -L "$target" ]] || fail "Checkout path exists but is not a Git repo: $target"
  run mkdir -p "$(dirname "$target")"
  run git clone --depth=1 "$url" "$target"
}
generate_init() {
  local file=$1
  shift
  run mkdir -p "$cache_dir"
  run /bin/bash -c 'file=$1; shift; "$@" > "$file.tmp" && mv "$file.tmp" "$file"' _ "$file" "$@"
}

apply_task() {
  case "$1" in
    core)
      case "$platform" in
        mac|arch) packages git curl ripgrep fd bat fzf jq zoxide unzip ;;
        debian) packages git curl ripgrep fd-find bat fzf jq zoxide unzip
          if ! $links_only; then
            link_file /usr/bin/fdfind "$HOME/.local/bin/fd"
            link_file /usr/bin/batcat "$HOME/.local/bin/bat"
          fi ;;
      esac ;;
    git)
      packages git gh git-delta
      config terminals/gh-dash gh-dash
      link_file "$repo_root/config/.gitconfig" "$HOME/.gitconfig"
      if ! $links_only; then
        if $dry_run; then
          info 'gh-dash is installed only when GitHub CLI is already authenticated.'
          run gh extension install dlvhdr/gh-dash
        elif gh auth status >/dev/null 2>&1; then
          local extensions
          extensions=$(gh extension list)
          [[ "$extensions" == *dlvhdr/gh-dash* ]] || run gh extension install dlvhdr/gh-dash
        else info 'Run gh auth login, then gh extension install dlvhdr/gh-dash.'; fi
      fi ;;
    fish)
      if [[ "$platform" == debian ]]; then packages fish starship curl; else packages fish starship atuin curl; fi
      config terminals/fish fish
      config suckless/atuin atuin
      config terminals/starship/config.toml starship.toml
      if ! $links_only; then
        run fish --no-config -c 'set -g fisher_path $argv[1]/fisherman; source $argv[1]/functions/fisher.fish; fisher update' "$repo_root/terminals/fish"
      fi ;;
    nvim)
      if [[ "$platform" == debian ]]; then
        packages curl build-essential cmake ninja-build unzip
        install_mise
        if ! $links_only; then run mise use --global neovim@latest; fi
      else packages neovim cmake ninja; fi
      if $dry_run; then info 'Requires nvim >= 0.12 before linking (no plugins are downloaded here).'
      else
        local nvim_command=(nvim)
        if [[ "$platform" == debian ]] && ! $links_only; then nvim_command=(mise exec neovim -- nvim)
        else command -v nvim >/dev/null || fail 'Install Neovim >= 0.12 before linking its config.'; fi
        run "${nvim_command[@]}" --headless -u NONE -i NONE --noplugin -c 'lua if vim.fn.has("nvim-0.12") == 0 then print("Config requires Neovim >= 0.12; install a current upstream release."); vim.cmd("cquit") end' -c qa
      fi
      config nvim nvim ;;
    tmux)
      packages tmux git
      if [[ "$platform" == mac ]]; then packages sesh; fi
      link_file "$repo_root/terminals/tmux/.tmux.conf" "$HOME/.tmux.conf"
      config terminals/sesh sesh
      config terminals/herdr/config.toml herdr/config.toml
      if ! $links_only; then clone_repo https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; fi ;;
    kitty)
      if [[ "$platform" == mac ]]; then casks kitty; else packages kitty; fi
      config terminals/kitty kitty ;;
    emacs)
      packages emacs
      link_file "$repo_root/.doom.d" "$HOME/.doom.d"
      link_file "$repo_root/.ideavimrc" "$HOME/.ideavimrc" ;;
    nnn) packages nnn; config suckless/nnn nnn ;;
    qutebrowser)
      if [[ "$platform" == mac ]]; then casks qutebrowser; else packages qutebrowser; fi
      config suckless/qutebrowser qutebrowser ;;
    runtimes) install_mise ;;
    ai)
      config opencode/opencode.jsonc opencode/opencode.jsonc
      config opencode/agents opencode/agents
      if [[ ! -L "$config_dir/opencode/skills" || "$(readlink "$config_dir/opencode/skills")" != "$HOME/.local/share/agent-hub/skills/opencode" ]]; then
        config ai/skills opencode/skills
      fi
      config opencode/AGENTS.md opencode/AGENTS.md
      config opencode/.i-have-adhd-always opencode/.i-have-adhd-always
      if [[ ! -L "$HOME/.claude/skills" || "$(readlink "$HOME/.claude/skills")" != "$HOME/.local/share/agent-hub/skills/claude" ]]; then
        link_file "$repo_root/ai/skills" "$HOME/.claude/skills"
      fi
      link_file "$repo_root/ai/CLAUDE.md" "$HOME/.claude/CLAUDE.md" ;;
    agent_hub)
      if ! $dry_run; then
        command -v node >/dev/null || fail 'Install Node 24+ before setting up Agent Hub.'
        command -v portless >/dev/null || fail 'Install Portless before setting up Agent Hub.'
        node -e 'if (Number(process.versions.node.split(".")[0]) < 24) process.exit(1)' || fail 'Agent Hub requires Node 24+.'
      fi
      if ! $links_only; then
        run npm --prefix "$repo_root/ai/agent-hub" ci --no-audit --no-fund
        run npm --prefix "$repo_root/ai/agent-hub" run build
        run node "$repo_root/ai/agent-hub/scripts/setup.mjs"
        run node "$repo_root/ai/agent-hub/scripts/service.mjs" install
      fi ;;
    nix) config nix nix; config home-manager home-manager ;;
    cli)
      packages gum television starship atuin eza bottom procs dust sd xh chafa tokei \
        shellcheck shfmt stylua watch hurl lazygit lazydocker
      if [[ "$platform" == mac ]]; then packages sesh serpl agavra/tap/tuicr; fi ;;
    ghostty|wezterm)
      if [[ "$platform" == mac ]]; then casks "$1"; else packages "$1"; fi
      config "terminals/$1" "$1" ;;
    nushell)
      packages nushell carapace starship atuin zoxide go
      generate_init "$cache_dir/atuin.nu" atuin init nu
      generate_init "$cache_dir/zoxide.nu" zoxide init nushell
      link_file "$cache_dir/atuin.nu" "$HOME/.local/share/atuin/init.nu"
      link_file "$cache_dir/zoxide.nu" "$HOME/.zoxide.nu"
      if [[ "$platform" == mac ]]; then link_file "$repo_root/terminals/nushell" "$HOME/Library/Application Support/nushell"
      else config terminals/nushell nushell; fi ;;
    fonts)
      if [[ "$platform" == mac ]]; then casks font-jetbrains-mono-nerd-font
      else packages ttf-jetbrains-mono-nerd; fi ;;
    yazi)
      packages yazi ffmpeg poppler jq fd ripgrep fzf zoxide
      config suckless/yazi yazi ;;
    devops)
      if [[ "$platform" == mac ]]; then
        casks docker
        packages lazydocker helm kubectx k9s kubernetes-cli hashicorp/tap/terraform hashicorp/tap/terraform-ls hashicorp/tap/vault
        link_file "$repo_root/suckless/k9s" "$HOME/Library/Application Support/k9s"
      else packages docker docker-compose lazydocker helm kubectx k9s kubectl terraform; config suckless/k9s k9s; fi ;;
    zsh) packages zsh mise television starship atuin zoxide pyenv; link_file "$repo_root/terminals/zsh/.zshrc" "$HOME/.zshrc" ;;
    rio) casks rio; config terminals/rio rio ;;
    desktop)
      casks nikitabobko/tap/aerospace font-satoshi sf-symbols font-sf-pro
      packages lua git felixkratz/formulae/sketchybar felixkratz/formulae/borders switchaudio-osx nowplaying-cli
      if ! $links_only; then
        clone_repo https://github.com/FelixKratz/SbarLua.git "$cache_dir/SbarLua"
        run make -C "$cache_dir/SbarLua" install
        run make -C "$repo_root/suckless/mac_os/sketchybar/helpers"
      fi
      config suckless/mac_os/aerospace aerospace
      config suckless/mac_os/sketchybar sketchybar
      link_file "$repo_root/sketchybar-app-font/dist/sketchybar-app-font.ttf" "$HOME/Library/Fonts/sketchybar-app-font.ttf" ;;
    karabiner) casks karabiner-elements; config suckless/mac_os/karabiner karabiner ;;
    editors)
      casks cursor zed
      link_file "$repo_root/suckless/mac_os/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
      link_file "$repo_root/suckless/mac_os/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
      config suckless/mac_os/zed/mappings.json zed/keymap.json
      config suckless/mac_os/zed/settings.json zed/settings.json
      if ! $links_only; then run /Applications/Cursor.app/Contents/Resources/app/bin/cursor --install-extension vscodevim.vim; fi ;;
    extras)
      casks marta mailspring
      packages superfile
      link_file "$repo_root/suckless/mac_os/marta/config" "$HOME/Library/Application Support/org.yanex.marta/conf.marco"
      link_file "$repo_root/suckless/superfile/config.toml" "$HOME/Library/Application Support/superfile/config.toml" ;;
    security) packages nmap openconnect openvpn; info 'Install ZAP manually: https://www.zaproxy.org/download/ (Homebrew cask is disabled).' ;;
    macos)
      $links_only && return 0
      run defaults write -g InitialKeyRepeat -int 10
      run defaults write -g KeyRepeat -int 1
      run defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
      run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
      run defaults write com.apple.finder DisableAllAnimations -bool true
      run defaults write com.apple.dock mru-spaces -bool false
      run mkdir -p "$HOME/Screen Shots"
      run defaults write com.apple.screencapture location -string "$HOME/Screen Shots" ;;
  esac
}

check_platform() {
  case "$platform:$(uname -s)" in
    mac:Darwin) ;;
    arch:Linux) command -v pacman >/dev/null || fail 'Arch setup requires pacman.' ;;
    debian:Linux) command -v apt-get >/dev/null || fail 'Debian/Ubuntu setup requires apt-get.' ;;
    *) fail "Cannot apply $platform setup on $(uname -s). Use --dry-run to preview it." ;;
  esac
  [[ $EUID -ne 0 ]] || fail 'Run as your normal user; package tasks request sudo when needed.'
}

preview=$dry_run
dry_run=true
heading "REVIEW / $platform"
printf '  Repository: %s\n  Config: %s\n  Tasks: %s\n' "$repo_root" "$config_dir" "${selected[*]}"
info 'Existing configs are preserved. No login-shell, SSH-key, hostname, or Spotlight changes.'
info 'Package tasks may request administrator access; downloaded upstream installers/builds are shown below.'
link_file "$repo_root" "$HOME/.dotfiles"
for current_task in "${selected[@]}"; do
  printf '\n  + %s\n' "$current_task"
  apply_task "$current_task"
done
if $preview; then info "Preview complete. Conflicts: $conflicts. No changes made."; exit 0; fi
check_platform
if ((conflicts > 0)) && ! $backup; then
  [[ -t 0 && -t 1 ]] && ! $yes || fail 'Conflicting configs found. Review --dry-run, then pass --backup to preserve them.'
  confirm "Back up $conflicts conflicting configs before linking?" || { info 'Cancelled. No changes made.'; exit 0; }
  backup=true
fi
if ! $yes; then
  [[ -t 0 && -t 1 ]] || fail 'No terminal: use --yes after reviewing --dry-run.'
  confirm 'Apply the selected setup tasks?' || { info 'Cancelled. No changes made.'; exit 0; }
fi

dry_run=false
manager_ready=false
umask 077
heading 'APPLY'
current_task=preflight
link_file "$repo_root" "$HOME/.dotfiles"
step=0
for current_task in "${selected[@]}"; do
  step=$((step+1))
  printf '\n  [%d/%d] %s\n' "$step" "${#selected[@]}" "$current_task"
  apply_task "$current_task"
  success "$current_task complete"
done
success 'Setup complete. Open a new terminal to use the linked configs.'
[[ ! -d "$backup_dir" ]] || info "Backups: $backup_dir"
info 'Manual steps and platform limits: bootstrap/README.md'
