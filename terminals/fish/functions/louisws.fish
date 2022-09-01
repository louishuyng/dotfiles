function louisws -d "working space of louis"
    set -l DEV_DIR "~/Dev/Projects"

    set -l OIVAN_PROJECT $DEV_DIR/Oivan/sakani-workspace/sakani-market-units-service
    set -l PRODUCTPINE_PROJECT $DEV_DIR/Productpine/brand-management-system

    set -l SESSION_OIVAN "Oivan"
    set -l SESSION_PRODUCTPINE "Productpine"
    set -l SESSION_SYS "System"

    # OIVAN
    initCodeSpace $SESSION_OIVAN $OIVAN_PROJECT

    # PRODUCTPINE
    # initCodeSpace $SESSION_PRODUCTPINE $PRODUCTPINE_PROJECT

    # System
    tmux kill-session -t $SESSION_SYS

    tmux new -d -s $SESSION_SYS -n "dotfiles"
    tmux send-keys -t $SESSION_SYS:1 "cd ~/.dotfiles" Enter
    # tmux send-keys -t $SESSION_SYS:1 "nvim" Enter

    tmux new-window -n "hacking"
    tmux -u attach-session -t $SESSION_SYS:1
end

function initCodeSpace -d 'helper init code space'
  set -l SESSION $argv[1]
  set -l PROJECT_DIR $argv[2]

  tmux kill-session -t $SESSION

  tmux new -d -s $SESSION -n "notes"
  tmux send-keys -t $SESSION:1.1 "cd ~/Dev/org/work" Enter
  tmux send-keys -t $SESSION:1.1 "nvim" Enter
  tmux send-keys -t $SESSION:1.1 ":NeorgStart" Enter
  tmux send-keys -t $SESSION:1.1 ":e $(echo $SESSION | string lower).norg" Enter

  tmux new-window -n "servers"
  tmux send-keys -t $SESSION:2.1 "cd $PROJECT_DIR" Enter
  tmux split-window -h
  tmux send-keys -t $SESSION:2.2 "cd $PROJECT_DIR" Enter
  tmux split-window -v
  tmux send-keys -t $SESSION:2.3 "cd $PROJECT_DIR" Enter

  tmux new-window -n "code"
  tmux send-keys -t $SESSION:3.1 "cd $PROJECT_DIR" Enter
  # tmux send-keys -t $SESSION:3.1 "nvim" Enter
end
