function gwip -d 'wip commit'
  # stage everything
  git add -A

  # Remove deleted files
  git rm $(git ls-files --deleted) 2> /dev/null

  # commit with message
  git commit -m "--wip-- [skip ci]" --no-verify --no-gpg-sign
end
