#!/opt/homebrew/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../sesh/roots.sh"

roots=$(mktemp)
trap 'rm -f -- "$roots"' EXIT
parse_roots "$roots"
cat "$roots"
zoxide query -l
