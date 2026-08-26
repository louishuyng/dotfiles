#!/opt/homebrew/bin/bash
# Playzone: ku-regask
# Open (or split) RegAsk:k9s-play running `ku`.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib.sh"

pz_ensure_session "RegAsk"
pz_open_or_split "RegAsk" "ku" "$HOME/LX14/repository/github.com/regask/k9s-play" "-v" "30%"
