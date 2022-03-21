function gb -d 'checkout git branch using fzf'
  is_in_git_repo || return

  git checkout (git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf-down --ansi --multi --tac --preview-window right:70% \
             --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" (echo {} | sed s/^..// | cut -d" " -f1)' |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##')
end

function is_in_git_repo
  git rev-parse HEAD > /dev/null 2>&1
end

function fzf-down
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview $argv
end
