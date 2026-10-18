#! /bin/bash
set -Eeuo pipefail

repo_root=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
bootstrap_test_dir=$(mktemp -d)
trap 'rm -rf "$bootstrap_test_dir"' EXIT
export bootstrap_test_dir
export XDG_CONFIG_HOME="$bootstrap_test_dir/config with spaces"
export XDG_STATE_HOME="$bootstrap_test_dir/state"
export XDG_CACHE_HOME="$bootstrap_test_dir/cache"
export command_log="$bootstrap_test_dir/commands"
export mock_os=Darwin mock_brew_fail=no mock_nvim_old=no mock_ln_fail=no
export mock_gh_fail=no
export mock_atuin_fail=no mock_cp_fail=no
mkdir -p "$XDG_CONFIG_HOME"
touch "$command_log"

# Run filesystem operations only inside this fixture; never change the real home.
mkdir() {
  local arg
  for arg in "$@"; do
    [[ "$arg" == -* ]] && continue
    [[ "$arg" == "$bootstrap_test_dir/"* ]] || continue
    command mkdir -p "$arg"
  done
}
ln() {
  local target=${!#}
  [[ "$target" == "$bootstrap_test_dir/"* ]] || return 0
  [[ "$mock_ln_fail" != yes ]] || return 19
  command ln "$@"
}
mv() {
  [[ "$1" == "$bootstrap_test_dir/"* && "$2" == "$bootstrap_test_dir/"* ]] || return 0
  command mv "$@"
}
cp() {
  if [[ "${!#}" == "$bootstrap_test_dir/"* && "$mock_cp_fail" == yes ]]; then return 19; fi
  command cp "$@"
}
brew() { printf 'brew %s\n' "$*" >> "$command_log"; [[ "$mock_brew_fail" != yes ]]; }
sudo() { printf 'sudo %s\n' "$*" >> "$command_log"; }
fish() { printf 'fish %s\n' "$*" >> "$command_log"; }
nvim() { [[ "$mock_nvim_old" != yes ]]; }
gh() {
  printf 'gh %s\n' "$*" >> "$command_log"
  [[ "$mock_gh_fail" != yes ]]
}
git() { printf 'git %s\n' "$*" >> "$command_log"; }
make() { printf 'make %s\n' "$*" >> "$command_log"; }
defaults() { printf 'defaults %s\n' "$*" >> "$command_log"; }
atuin() { [[ "$mock_atuin_fail" != yes ]] && printf '# atuin init\n'; }
zoxide() { printf '# zoxide init\n'; }
mise() { printf 'mise %s\n' "$*" >> "$command_log"; }
uname() { printf '%s\n' "$mock_os"; }
pacman() { :; }
apt-get() { :; }
export -f mkdir ln mv cp brew sudo fish nvim gh git make defaults atuin zoxide mise uname pacman apt-get

assert_output() { [[ "$(cat "$bootstrap_test_dir/output")" == *"$1"* ]]; }
expect_failure() {
  if /bin/bash "$repo_root/bootstrap/mac.sh" "$@" >"$bootstrap_test_dir/output" 2>&1; then
    printf 'Expected failure: %s\n' "$*" >&2; exit 1
  fi
}

for platform in mac arch debian; do
  /bin/bash "$repo_root/bootstrap/$platform.sh" --help >"$bootstrap_test_dir/output"
  /bin/bash "$repo_root/bootstrap/$platform.sh" --list >"$bootstrap_test_dir/tasks"
  task_ids=$(cut -d ' ' -f 1 "$bootstrap_test_dir/tasks" | paste -sd, -)
  /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks "$task_ids" --dry-run --backup --plain >"$bootstrap_test_dir/output"
  assert_output 'No changes made.'
  [[ ! -s "$command_log" ]]
  [[ ! -e "$XDG_CONFIG_HOME/fish" && ! -e "$XDG_STATE_HOME" && ! -e "$XDG_CACHE_HOME" ]]
done
printf 'OK: every task previews on all three platforms without side effects\n'

relocated="$bootstrap_test_dir/checkout with spaces"
mkdir -p "$relocated/bootstrap"
relocated=$(cd -P "$relocated" && pwd)
cp "$repo_root/bootstrap/mac.sh" "$repo_root/bootstrap/setup.sh" "$relocated/bootstrap/"
for directory in terminals nvim suckless; do command ln -s "$repo_root/$directory" "$relocated/$directory"; done
/bin/bash "$relocated/bootstrap/mac.sh" --tasks fish,nvim --dry-run --plain >"$bootstrap_test_dir/output"
assert_output "Repository: $relocated"
[[ ! -s "$command_log" ]]

for platform in mac arch debian; do
  omp_home="$bootstrap_test_dir/omp-$platform"
  omp_agent="$omp_home/.omp/agent"
  omp_state="$omp_home/state"
  mkdir -p "$omp_agent/sessions" "$omp_home/.local/share/agent-hub/skills/omp"
  printf 'local preferences\n' >"$omp_agent/config.yml"
  printf 'private MCP headers\n' >"$omp_agent/mcp.json"
  printf 'saved conversation\n' >"$omp_agent/sessions/keep.jsonl"
  printf 'local database\n' >"$omp_agent/agent.db"
  command ln -s "$omp_home/.local/share/agent-hub/skills/omp" "$omp_agent/skills"
  if [[ "$platform" == mac ]]; then mock_os=Darwin; else mock_os=Linux; fi
  if HOME="$omp_home" XDG_STATE_HOME="$omp_state" /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks ai --links-only --yes >"$bootstrap_test_dir/output" 2>&1; then
    printf 'Expected existing OMP config to require backup permission\n' >&2; exit 1
  fi
  [[ "$(cat "$omp_agent/config.yml")" == 'local preferences' ]]
  [[ "$(cat "$omp_agent/mcp.json")" == 'private MCP headers' ]]
  [[ ! -e "$omp_state" ]]
  HOME="$omp_home" XDG_STATE_HOME="$omp_state" /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks ai --links-only --backup --yes >"$bootstrap_test_dir/output"
  saved=("$omp_state"/dotfiles-bootstrap/backups/*/.omp/agent)
  [[ "$(cat "${saved[0]}/config.yml")" == 'local preferences' ]]
  [[ "$(cat "${saved[0]}/mcp.json")" == 'private MCP headers' ]]
  cmp "$omp_agent/config.yml" "$repo_root/ai/config/native-omp.yml"
  cmp "$omp_agent/mcp.json" "$repo_root/ai/config/native-omp-mcp.json"
  [[ "$(readlink "$omp_agent/keybindings.yml")" == "$repo_root/ai/config/native-omp-keybindings.yml" ]]
  [[ "$(readlink "$omp_agent/AGENTS.md")" == "$repo_root/ai/AGENTS.md" ]]
  [[ "$(readlink "$omp_agent/skills")" == "$omp_home/.local/share/agent-hub/skills/omp" ]]
  [[ "$(cat "$omp_agent/sessions/keep.jsonl")" == 'saved conversation' ]]
  [[ "$(cat "$omp_agent/agent.db")" == 'local database' ]]
  backup_count=$(find "$omp_state" -type f | wc -l)
  HOME="$omp_home" XDG_STATE_HOME="$omp_state" /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks ai --links-only --yes >"$bootstrap_test_dir/output"
  [[ "$(find "$omp_state" -type f | wc -l)" == "$backup_count" ]]
  command rm "$omp_agent/skills"
  HOME="$omp_home" XDG_STATE_HOME="$omp_state" /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks ai --links-only --yes >"$bootstrap_test_dir/output"
  [[ "$(readlink "$omp_agent/skills")" == "$repo_root/ai/skills" ]]
done
mock_os=Darwin
[[ ! -s "$command_log" ]]
printf 'OK: OMP configs backed up on every platform; managed skills, runtime state, and reruns preserved\n'

for location in default override; do
  tern_home="$bootstrap_test_dir/tern-$location"
  tern_dir="$tern_home/Library/Application Support/Tern"
  tern_override=
  if [[ "$location" == override ]]; then
    tern_dir="$tern_home/custom config"
    tern_override=$tern_dir
  fi
  tern_state="$tern_home/state"
  mkdir -p "$tern_dir/plugins/another-plugin"
  printf 'local Tern preferences\n' >"$tern_dir/settings.json"
  printf 'saved sessions\n' >"$tern_dir/daemon.state"
  printf 'private key\n' >"$tern_dir/host_key"
  printf 'unrelated plugin\n' >"$tern_dir/plugins/another-plugin/plugin.toml"
  if HOME="$tern_home" TERN_CONFIG_DIR="$tern_override" XDG_STATE_HOME="$tern_state" /bin/bash "$repo_root/bootstrap/mac.sh" --tasks tern --links-only --yes >"$bootstrap_test_dir/output" 2>&1; then
    printf 'Expected existing Tern config to require backup permission\n' >&2; exit 1
  fi
  [[ "$(cat "$tern_dir/settings.json")" == 'local Tern preferences' ]]
  [[ ! -e "$tern_state" ]]
  HOME="$tern_home" TERN_CONFIG_DIR="$tern_override" XDG_STATE_HOME="$tern_state" /bin/bash "$repo_root/bootstrap/mac.sh" --tasks tern --links-only --backup --yes >"$bootstrap_test_dir/output"
  saved=("$tern_state"/dotfiles-bootstrap/backups/*/"${tern_dir#"$tern_home"/}"/settings.json)
  [[ "$(cat "${saved[0]}")" == 'local Tern preferences' ]]
  [[ ! -L "$tern_dir/settings.json" ]]
  cmp "$tern_dir/settings.json" "$repo_root/terminals/tern/settings.json"
  [[ "$(readlink "$tern_dir/plugins/tool-keys")" == "$repo_root/terminals/tern" ]]
  [[ "$(cat "$tern_dir/daemon.state")" == 'saved sessions' ]]
  [[ "$(cat "$tern_dir/host_key")" == 'private key' ]]
  [[ "$(cat "$tern_dir/plugins/another-plugin/plugin.toml")" == 'unrelated plugin' ]]
  backup_count=$(find "$tern_state" -type f | wc -l)
  HOME="$tern_home" TERN_CONFIG_DIR="$tern_override" XDG_STATE_HOME="$tern_state" /bin/bash "$repo_root/bootstrap/mac.sh" --tasks tern --links-only --yes >"$bootstrap_test_dir/output"
  [[ "$(find "$tern_state" -type f | wc -l)" == "$backup_count" ]]
  printf 'changed UI preferences\n' >"$tern_dir/settings.json"
  mock_cp_fail=yes
  if HOME="$tern_home" TERN_CONFIG_DIR="$tern_override" XDG_STATE_HOME="$tern_state" /bin/bash "$repo_root/bootstrap/mac.sh" --tasks tern --links-only --backup --yes >"$bootstrap_test_dir/output" 2>&1; then
    printf 'Expected Tern copy failure\n' >&2; exit 1
  fi
  assert_output 'previous config was restored'
  [[ "$(cat "$tern_dir/settings.json")" == 'changed UI preferences' ]]
  mock_cp_fail=no
done
[[ ! -s "$command_log" ]]
printf 'OK: Tern settings backed up; custom config paths, unrelated plugins, private state, and reruns preserved\n'

for argument in unknown 'fish,,git' 'fish,' ',fish' $'fish\nmacos' __list; do expect_failure --tasks "$argument" --dry-run; done
expect_failure --tasks
expect_failure --yes
expect_failure --bad-option
/bin/bash "$repo_root/bootstrap/mac.sh" --tasks macos --links-only --yes >"$bootstrap_test_dir/output"
[[ ! -s "$command_log" ]]
# A Linux entry point must refuse application on macOS.
if /bin/bash "$repo_root/bootstrap/arch.sh" --tasks fish --links-only --yes >"$bootstrap_test_dir/output" 2>&1; then exit 1; fi
assert_output 'Cannot apply arch setup on Darwin'
printf 'OK: argument and platform guards\n'

mkdir -p "$XDG_CONFIG_HOME/fish"
printf 'keep my config\n' >"$XDG_CONFIG_HOME/fish/config.fish"
expect_failure --tasks fish --links-only --yes
assert_output 'Conflicting configs found'
[[ "$(cat "$XDG_CONFIG_HOME/fish/config.fish")" == 'keep my config' ]]
[[ ! -e "$XDG_STATE_HOME" ]]

/bin/bash "$repo_root/bootstrap/mac.sh" --tasks fish --links-only --backup --yes >"$bootstrap_test_dir/output"
[[ "$(readlink "$XDG_CONFIG_HOME/fish")" == "$repo_root/terminals/fish" ]]
saved=$(find "$XDG_STATE_HOME" -name config.fish -type f)
[[ "$(cat "$saved")" == 'keep my config' ]]
backup_count=$(find "$XDG_STATE_HOME" -type f | wc -l)
/bin/bash "$repo_root/bootstrap/mac.sh" --tasks fish,fish --links-only --yes >"$bootstrap_test_dir/output"
assert_output '[1/1] fish'
assert_output 'Already linked:'
[[ "$(find "$XDG_STATE_HOME" -type f | wc -l)" == "$backup_count" ]]
[[ ! -s "$command_log" ]]
printf 'OK: conflicts preserved, paths with spaces, reruns, and task deduplication\n'

command rm "$XDG_CONFIG_HOME/fish"
command ln -s /missing/fish "$XDG_CONFIG_HOME/fish"
/bin/bash "$repo_root/bootstrap/mac.sh" --tasks fish --links-only --backup --yes >"$bootstrap_test_dir/output"
[[ "$(readlink "$XDG_CONFIG_HOME/fish")" == "$repo_root/terminals/fish" ]]
[[ -n "$(find "$XDG_STATE_HOME" -type l -name fish)" ]]

command rm "$XDG_CONFIG_HOME/fish"
mkdir -p "$XDG_CONFIG_HOME/fish"
printf 'restore me\n' >"$XDG_CONFIG_HOME/fish/config.fish"
mock_ln_fail=yes
expect_failure --tasks fish --links-only --backup --yes
assert_output 'previous config was restored'
[[ "$(cat "$XDG_CONFIG_HOME/fish/config.fish")" == 'restore me' ]]
mock_ln_fail=no
printf 'OK: dangling links backed up and failed link replacement restored\n'

mock_brew_fail=yes
expect_failure --tasks core --yes
assert_output 'core failed'
assert_output '--tasks core'
mock_brew_fail=no
>"$command_log"
mock_nvim_old=yes
expect_failure --tasks nvim --links-only --yes
assert_output 'nvim failed'
[[ ! -e "$XDG_CONFIG_HOME/nvim" ]]
mock_nvim_old=no
printf 'OK: package failures stop with a retry command; old Neovim is not linked\n'

mock_gh_fail=yes
/bin/bash "$repo_root/bootstrap/mac.sh" --tasks git --yes >"$bootstrap_test_dir/output"
assert_output 'Run gh auth login'
[[ "$(cat "$command_log")" != *'gh extension install'* ]]
mock_gh_fail=no

/bin/bash "$repo_root/bootstrap/mac.sh" --tasks nushell --backup --yes >"$bootstrap_test_dir/output"
[[ "$(cat "$XDG_CACHE_HOME/dotfiles-bootstrap/atuin.nu")" == '# atuin init' ]]
[[ "$(cat "$XDG_CACHE_HOME/dotfiles-bootstrap/zoxide.nu")" == '# zoxide init' ]]
mock_atuin_fail=yes
expect_failure --tasks nushell --backup --yes
assert_output 'nushell failed'
[[ "$(cat "$XDG_CACHE_HOME/dotfiles-bootstrap/atuin.nu")" == '# atuin init' ]]
mock_atuin_fail=no
printf 'OK: shell init generation preserves previous output on failure\n'

for platform in arch debian; do
  mock_os=Linux
  /bin/bash "$repo_root/bootstrap/$platform.sh" --tasks nnn --links-only --yes >"$bootstrap_test_dir/output"
  [[ "$(readlink "$XDG_CONFIG_HOME/nnn")" == "$repo_root/suckless/nnn" ]]
done
/bin/bash "$repo_root/bootstrap/debian.sh" --tasks nvim --yes >"$bootstrap_test_dir/output"
[[ "$(cat "$command_log")" == *'mise use --global neovim@latest'* ]]
[[ "$(readlink "$XDG_CONFIG_HOME/nvim")" == "$repo_root/nvim" ]]
printf 'OK: unauthenticated GitHub setup stays manual; Linux links use the same safe flow\n'
printf 'Bootstrap checks passed\n'
