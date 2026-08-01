#!/opt/homebrew/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Approve Backstage
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🎭
# @raycast.argument1 { "type": "text", "placeholder": "Approval links or IDs" }

# Documentation:
# @raycast.author louishuyng
# @raycast.authorURL https://raycast.com/louishuyng

# Absolute path: the `bsr` alias is fish-only and Raycast runs with a trimmed PATH
BSR=/opt/homebrew/bin/backstage-regask

mapfile -t APPROVALS < <(tr ' \t\n' '\n' <<< "$1" | grep -v '^[[:space:]]*$')

if [ ${#APPROVALS[@]} -eq 0 ]; then
  echo "Usage: pass one or more Backstage approval links or IDs"
  exit 1
fi

FAILED=0

for APPROVAL in "${APPROVALS[@]}"; do
  if "$BSR" approve "$APPROVAL"; then
    echo "✅ Approved: $APPROVAL"
  else
    echo "❌ Failed: $APPROVAL"
    FAILED=1
  fi
  echo
done

exit $FAILED
