function gunwip -d 'unwip recentl WIP commit'
  git rev-list --max-count=1 --format="%s" HEAD | grep -q -- "\--wip--" && git reset HEAD~1
end
