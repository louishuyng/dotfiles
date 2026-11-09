#! /bin/bash
# Refresh the vendored Elephant-Goldfish Model (native plugins are synced separately).
# Usage: scripts/update-egm.sh [git-ref]   (default: the ref in ai/vendor/egm/vendor.json)
set -e
exec node "$(cd "$(dirname "$0")/.." && pwd)/ai/agent-hub/scripts/vendor.mjs" update egm "$@"
