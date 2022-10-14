function louisws -d "working space of louis"
    set -l DEV_DIR "~/Dev/Projects"
    set -l ORG_DIR "~/Dev/org/"

    set -l DEV_PROJECT $DEV_DIR/

    set -l SESSION_ORG "Org"
    set -l SESSION_DEV "Dev"
    set -l SESSION_SYS "System"

    # Org
    tmux kill-session -t $SESSION_ORG

    tmux new -d -s $SESSION_ORG -n "work"
    tmux send-keys -t $SESSION_ORG:1 "cd $ORG_DIR/work" Enter
    tmux send-keys -t $SESSION_ORG:1 "nv index.norg" Enter

    tmux new-window -n "life"
    tmux send-keys -t $SESSION_ORG:2 "cd $ORG_DIR/life" Enter
    tmux send-keys -t $SESSION_ORG:2 "nv index.norg" Enter

    # DEV
    initCodeSpace $SESSION_DEV $DEV_PROJECT

    # System
    tmux kill-session -t $SESSION_SYS

    tmux new -d -s $SESSION_SYS -n "dotfiles"
    tmux send-keys -t $SESSION_SYS:1 "cd ~/.dotfiles" Enter
    tmux send-keys -t $SESSION_SYS:1 "nvim" Enter

    tmux new-window -n "hack"
    tmux -u attach-session -t $SESSION_ORG:1
end

function initCodeSpace -d 'helper init code space'
  set -l SESSION $argv[1]
  set -l PROJECT_DIR $argv[2]

  tmux kill-session -t $SESSION

  tmux new -d -s $SESSION -n "servers"
  tmux send-keys -t $SESSION:1.1 "cd $PROJECT_DIR" Enter
  tmux split-window -h
  tmux send-keys -t $SESSION:1.2 "cd $PROJECT_DIR" Enter
  tmux split-window -v
  tmux send-keys -t $SESSION:1.3 "cd $PROJECT_DIR" Enter

  tmux new-window -n "code"
  tmux send-keys -t $SESSION:2.1 "cd $PROJECT_DIR" Enter
end
