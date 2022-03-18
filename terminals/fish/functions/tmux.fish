function louisws -d "working space of louis"
    set -l DEV_DIR "~/Dev/Projects"

    set -l OIVAN_PROJECT $DEV_DIR/Oivan/sakani-workspace
    set -l PRODUCTPINE_PROJECT $DEV_DIR/Productpine

    set -l SESSION_ORG "Org Mode"
    set -l SESSION_OIVAN "Oivan"
    set -l SESSION_PRODUCTPINE "Productpine"
    set -l SESSION_DEVOPS "Devops"

    # ORG
    tmux kill-session -t $SESSION_ORG
    tmux new -d -s $SESSION_ORG -n "work"
    tmux send-keys -t $SESSION_ORG:1 "cd ~/Dev/org/work" Enter
    tmux send-keys -t $SESSION_ORG:1 "nvim" Enter
    tmux send-keys -t $SESSION_ORG:1 ":NeorgStart" Enter

    tmux new-window -n "life"
    tmux send-keys -t $SESSION_ORG:2 "cd ~/Dev/org/life" Enter
    tmux send-keys -t $SESSION_ORG:2 "nvim" Enter
    tmux send-keys -t $SESSION_ORG:2 ":NeorgStart" Enter

    # OIVAN
    initCodeSpace $SESSION_OIVAN $OIVAN_PROJECT
    setupRemoteOivan $SESSION_OIVAN

    # PRODUCTPINE
    initCodeSpace $SESSION_PRODUCTPINE $PRODUCTPINE_PROJECT

    # DEVOPS
    tmux kill-session -t $SESSION_DEVOPS

    tmux new -d -s $SESSION_DEVOPS -n "dotfiles"
    tmux send-keys -t $SESSION_DEVOPS:1 "cd ~/.dotfiles" Enter
    tmux send-keys -t $SESSION_DEVOPS:1 "nvim" Enter

    tmux new-window -n "dadbod"
    tmux send-keys -t $SESSION_DEVOPS:2 "nvim" Enter
    tmux send-keys -t $SESSION_DEVOPS:2 " vd" Enter

    tmux new-window -n "rocky"
    tmux send-keys -t $SESSION_DEVOPS:3 "ssh_join rocky" Enter

    tmux -u attach-session -t $SESSION_DEVOPS:3
end

function initCodeSpace -d 'helper init code space'
  set -l SESSION $argv[1]
  set -l PROJECT_DIR $argv[2]

  tmux kill-session -t $SESSION

  tmux new -d -s $SESSION -n "code"
  tmux send-keys -t $SESSION:1 "cd $PROJECT_DIR" Enter
  tmux send-keys -t $SESSION:1 "nvim" Enter
  tmux send-keys -t $SESSION:1 " p" Enter

  tmux new-window -n "local-logs"
  tmux send-keys -t $SESSION:2.1 "cd $PROJECT_DIR" Enter
  tmux split-window -h
  tmux send-keys -t $SESSION:2.2 "cd $PROJECT_DIR" Enter
  tmux split-window -v
  tmux send-keys -t $SESSION:2.3 "cd $PROJECT_DIR" Enter
end

function setupRemoteOivan -d 'set up remote oivan'
  set -l SESSION $argv[1]

  tmux new-window -n "remote-servers"

  tmux send-keys -t $SESSION:3.1 "vpnup oivan" Enter
  tmux split-window -h

  tmux send-keys -t $SESSION:3.2 "sshadd oivan" Enter
  tmux send-keys -t $SESSION:3.2 "ssh dev" Enter

  tmux split-window -v

  tmux send-keys -t $SESSION:3.3 "sshadd oivan" Enter
  tmux send-keys -t $SESSION:3.3 "ssh test" Enter
end
