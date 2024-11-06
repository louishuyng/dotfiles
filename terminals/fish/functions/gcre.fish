function gcre -d 'git commit regask'
  set -l TYPE $(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

  # Get the ticket number from branch for example if branch is REG-1234-branch-name
  # then the TICKET will be [REG-1234]
  # If REG-XXXX-branch-name is the branch name then TICKET will be [REG-XXXX]
  set -l TICKET $(git rev-parse --abbrev-ref HEAD | string match -r '([A-Z]+-[0-9A-Z]+)' | tail -n 1)
  set -l TICKET (if test -n "$TICKET" ; echo "[$TICKET]" ; end)

  # Pre-populate the input with the type(scope): so that the user may change it
  set -l SUMMARY $(gum input --value "$TYPE$TICKET: " --placeholder "Summary of this change")
  set -l DESCRIPTION $(gum write --placeholder "Details of this change (CTRL+D to finish)")

  # Commit the changes
  git commit -m "$SUMMARY" -m "$DESCRIPTION" --no-verify
end
