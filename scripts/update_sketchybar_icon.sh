#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
font_repo=${SKETCHYBAR_APP_FONT_DIR:-"$HOME/.cache/sketchybar-app-font"}
icon_map="$repo_root/suckless/mac_os/sketchybar/helpers/app_icons.lua"
font="$HOME/Library/Fonts/sketchybar-app-font.ttf"

command -v pnpm >/dev/null || {
	echo "pnpm is required to build sketchybar-app-font" >&2
	exit 1
}

if [[ -d "$font_repo/.git" ]]; then
	git -C "$font_repo" pull --ff-only
else
	rm -rf "$font_repo"
	git clone --depth=1 https://github.com/kvndrsslr/sketchybar-app-font.git "$font_repo"
fi

pnpm --dir "$font_repo" install --frozen-lockfile
pnpm --dir "$font_repo" run build

mkdir -p "$(dirname "$font")"
cp "$font_repo/dist/sketchybar-app-font.ttf" "$font"
cp "$font_repo/dist/icon_map.lua" "$icon_map"

if command -v stylua >/dev/null; then
	stylua "$icon_map"
fi

if command -v sketchybar >/dev/null; then
	sketchybar --reload
fi
