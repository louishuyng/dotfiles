#! /bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/AppSwitcher.app"

mkdir -p "$APP/Contents/MacOS"
swiftc -O "$DIR/main.swift" -o "$APP/Contents/MacOS/AppSwitcher"
cp "$DIR/Info.plist" "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

pkill -x AppSwitcher || true
echo "built $APP — double-tap ⌘ to open"
