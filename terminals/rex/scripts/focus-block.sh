#!/bin/bash
# focus-block.sh <session_id>:<block_id> — bring Rex Beta to the front on that block (sketchybar pilo row click).
# Switching the app's session is session.select, which it takes from the CLI only with Remote Control on.
set -u
REX="/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
session=${1%%:block:*}
block=block:${1#*:block:}
open -b com.superlogical.rex
"$REX" --autostart=false focus -s "$session" "$block" >/dev/null 2>&1
client=$("$REX" --autostart=false client ls --json | jq -r '[.clients[] | select(.info.kind == "app")][0].client_id // empty')
[ -n "$client" ] && "$REX" -C "$client" do session.select session_id="$session" >/dev/null 2>&1
exit 0
