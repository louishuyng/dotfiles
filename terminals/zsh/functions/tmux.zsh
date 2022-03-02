# Working Space
function louisws () {
    DEV_DIR="~/Dev/Projects"

    OIVAN_PROJECT="$DEV_DIR/Oivan/sakani-workspace"
    PRODUCTPINE_PROJECT="$DEV_DIR/Productpine"

    SESSION_OIVAN='Oivan'
    SESSION_PRODUCTPINE="Productpine"
    SESSION_DEVOPS='Devops'

    # OIVAN
    $(initCodeSpace $SESSION_OIVAN $OIVAN_PROJECT)
    $(setupRemoteOivan $SESSION_OIVAN)

    # PRODUCTPINE
    $(initCodeSpace $SESSION_PRODUCTPINE $PRODUCTPINE_PROJECT)

    # DEVOPS
    tmux kill-session -t $SESSION_DEVOPS

    tmux new -d -s $SESSION_DEVOPS -n "dotfiles"
    tmux send-keys -t $SESSION_DEVOPS:1 "cd ~/.dotfiles" Enter
    tmux send-keys -t $SESSION_DEVOPS:1 "nvim" Enter

    tmux -u attach-session -t $SESSION_DEVOPS:1
}

function initCodeSpace() {
  SESSION=$1
  PROJECT_DIR=$2

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
}

function setupRemoteOivan() {
  SESSION=$1

  tmux new-window -n "remote-servers"

  tmux send-keys -t $SESSION:3.1 "vpnup oivan" Enter
  tmux split-window -h

  tmux send-keys -t $SESSION:3.2 "sshadd oivan" Enter
  tmux send-keys -t $SESSION:3.2 "ssh dev" Enter

  tmux split-window -v

  tmux send-keys -t $SESSION:3.3 "sshadd oivan" Enter
  tmux send-keys -t $SESSION:3.3 "ssh test" Enter
}
