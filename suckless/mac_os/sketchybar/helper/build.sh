#!/bin/bash
# Build the Swift helpers next to their sources (needs Xcode Command Line Tools: xcode-select --install).
# The binaries are not kept in the repo — they are built here.
set -e
cd "$(dirname "$0")"
for f in *.swift; do
  n="${f%.swift}"; [ "$n" = wifiscan ] && continue
  echo "build $n"; swiftc -O "$f" -o "$n"
done
# Wi-Fi scan needs Location permission, which macOS only grants to an app bundle → wrap it in a tiny agent app (ad-hoc signed).
APP="WifiScan.app"; rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
echo "build $APP"; swiftc -O wifiscan.swift -o "$APP/Contents/MacOS/WifiScan"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>local.sketchybar.wifiscan</string>
  <key>CFBundleName</key><string>SketchyBar Wi-Fi Scan</string>
  <key>CFBundleDisplayName</key><string>SketchyBar Wi-Fi Scan</string>
  <key>CFBundleExecutable</key><string>WifiScan</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSLocationUsageDescription</key><string>Reads nearby Wi-Fi names so the SketchyBar Wi-Fi popup can list saved networks in range. Location is never stored or sent.</string>
  <key>NSLocationWhenInUseUsageDescription</key><string>Reads nearby Wi-Fi names so the SketchyBar Wi-Fi popup can list saved networks in range. Location is never stored or sent.</string>
</dict></plist>
PLIST
codesign --force --sign - "$APP" >/dev/null 2>&1 || true
echo "done"
