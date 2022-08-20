function gcm -d 'git commit using gum for more joyful interact'
  set -l TYPE $(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
  set -l SCOPE $(gum input --placeholder "scope")

  # Since the scope is optional, wrap it in parentheses if it has a value.
  if test -n "$SCOPE" 
    set -l SCOPE "($SCOPE)"
  end

  # Pre-populate the input with the type(scope): so that the user may change it
  set -l SUMMARY $(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
  set -l DESCRIPTION $(gum write --placeholder "Details of this change (CTRL+D to finish)")

  # Commit these changes
  gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"
end
