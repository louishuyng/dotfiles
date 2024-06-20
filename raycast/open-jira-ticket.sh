#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Jira ticket
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Ticket No" }
# @raycast.packageName open-jira-ticket

# Documentation:
# @raycast.author louishuyng
# @raycast.authorURL https://raycast.com/louishuyng

open "https://regask.atlassian.net/browse/REG-$1"
