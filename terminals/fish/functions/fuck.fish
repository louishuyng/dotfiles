function fuck --description "just commit i want to do it fast"
  git add .

  switch $argv[1]
    case ci
      set commit_message "chore: ci update"
    case bug
      set commit_message "chore: fix small bug"
    case changes
      set commit_message "chore: small changes"
    case typo
      set commit_message "chore: fix typo"
    case syntax
      set commit_message "chore: fix syntax"
  end

  # Fuck as i don't care some git hooks
  git commit -m $commit_message --no-verify

  # Nevermind just push it to HEAD i dont give a care
  git push origin HEAD
end
