function gunwipall -d 'unwip all WIP commits'
  set commit (git log --grep="--wip--" --invert-grep --max-count=1 --format=format:"%H")

  # Check if a commit without "--wip--" is found and it's not the same as HEAD
  if test "$commit" != (git rev-parse HEAD)
    git reset $commit || return 1
  end
end
