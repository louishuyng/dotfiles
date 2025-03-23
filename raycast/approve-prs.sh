#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Approve PRs
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ✅
# @raycast.argument1 { "type": "text", "placeholder": "URLs" }

# Documentation:
# @raycast.author louishuyng
# @raycast.authorURL https://raycast.com/louishuyng

# Each PR URL is separated by a end of line character
# We need to split the input string by the end of line character
# Also, remove any trailing white spaces
PR_URLS=$(echo $1 | tr " " "\n" | sed -e 's/[[:space:]]*$//')

# Loop through each PR URL
for PR_URL in $PR_URLS
do
  gh pr review $PR_URL --approve
  echo "Approved PR: $PR_URL ✅"

  # Add some delay to avoid other people think you are a bot
  # Sleep random time between 1 to 5 seconds
  sleep $((1 + RANDOM % 5))
done
