# Author:  halostatue/fish-fzf 
function gb -d 'checkout git branch, sorted by most recent commit, 30 latest branches'
  set -l branches (git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)')
  and set -l branch (string replace -a ' ' '\n' $branches | fzf-tmux -d (math 2 + (count $branches)) +m)
  and git checkout (echo $branch | sed -e 's/.* //' -e '#remotes/[^/]*/##')
end
