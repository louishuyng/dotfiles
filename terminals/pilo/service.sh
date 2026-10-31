#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
mkdir -p "$HOME/.pilo/logs"
echo $$ > "$HOME/.pilo/server.pid"
exec node "$HOME/.local/lib/node_modules/@garamnohhh/pilo/src/server.js"
