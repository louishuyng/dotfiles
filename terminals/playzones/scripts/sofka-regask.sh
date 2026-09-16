#!/opt/homebrew/bin/bash
# Playzone: sofka-regask
# Open (or split) RegAsk:k9s-play running `sofka`.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib.sh"

pz_ensure_session "RegAsk"
pz_open_or_split "RegAsk" "sofka" "$HOME/LX14/repository/github.com/regask/k9s-play" "-v" "30%"
