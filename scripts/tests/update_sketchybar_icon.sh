#!/usr/bin/env bash
set -euo pipefail

updater=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/update_sketchybar_icon.sh
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/font_repo/.git"
export SKETCHYBAR_APP_FONT_DIR="$test_dir/font_repo"
export command_log="$test_dir/commands"
export service_running

# Keep the real updater's network, installation, and desktop effects isolated.
git() { :; }
pnpm() { :; }
mkdir() { :; }
cp() { :; }
stylua() { :; }
sketchybar() { echo "sketchybar $*" >> "$command_log"; }
launchctl() {
	if [[ $1 == print ]]; then
		[[ $service_running != no ]]
	else
		echo "launchctl $*" >> "$command_log"
		[[ $service_running != fail ]]
	fi
}
export -f git pnpm mkdir cp stylua sketchybar launchctl

service_running=yes
bash "$updater"
[[ $(cat "$command_log") == "launchctl kickstart -k gui/$(id -u)/homebrew.mxcl.sketchybar" ]]

service_running=no
> "$command_log"
bash "$updater" > "$test_dir/output"
[[ $(cat "$command_log") == "sketchybar --reload" ]]
[[ $(cat "$test_dir/output") == *"Restart your SketchyBar process"* ]]

service_running=fail
> "$command_log"
if bash "$updater"; then
	echo "Expected a failed service restart to fail the updater" >&2
	exit 1
fi

echo "SketchyBar updater checks passed"
