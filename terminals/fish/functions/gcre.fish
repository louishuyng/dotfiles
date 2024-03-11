function gcre -d 'git commit regask'
  set -l TYPE $(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
  set -l TICKET $(gum input --placeholder "ticket no")

  if test -z $TICKET
    set TICKET "[REG-XXXX]"
  else
    set TICKET "[REG-$TICKET]"
  end

  # Pre-populate the input with the type(scope): so that the user may change it
  set -l SUMMARY $(gum input --value "$TYPE$TICKET: " --placeholder "Summary of this change")
  set -l DESCRIPTION $(gum write --placeholder "Details of this change (CTRL+D to finish)")

  # Commit these changes
  git commit -m "$SUMMARY" -m "$DESCRIPTION" --no-verify
end
