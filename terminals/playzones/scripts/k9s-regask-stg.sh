#!/opt/homebrew/bin/bash
# Playzone: k9s-regask-staging
# Open (or split) LX-REGASK:k9s-play running `regask-staging`.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib.sh"

pz_ensure_session "LX-REGASK"
pz_open_or_split "LX-REGASK" "regask-staging" "$HOME/LX14/repository/github.com/regask/k9s-play" "-v" "30%"
