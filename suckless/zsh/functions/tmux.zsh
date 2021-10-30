function dev() {
  str="$*"
  tmux -u new -s $str
}

function codeSpace () {
    DEV_DIR="~/Dev/Projects"

    OIVAN_PROJECT="$DEV_DIR/Oivan/sakani-workspace"
    ELXR_PROJECT="$DEV_DIR/ELXR"

    SESSION_CODE='Code'
    SESSION_DEVOPS='Devops'
    SESSION_SANDBOX='Sandbox'

    # CODE
    tmux kill-session -t $SESSION_CODE
    tmux new -d -s $SESSION_CODE -n "market"
    tmux new-window -n "v3-fe"
    tmux new-window -n "admin-fe"
    tmux new-window -n "sapa-fe"
    tmux new-window -n "elxr"

    tmux send-keys -t $SESSION_CODE:1 "cd $OIVAN_PROJECT/sakani-market-units-service" Enter
    tmux send-keys -t $SESSION_CODE:1 "nvim" Enter
    tmux send-keys -t $SESSION_CODE:2 "cd $OIVAN_PROJECT/sakani-v3-frontend" Enter
    tmux send-keys -t $SESSION_CODE:2 "nvim" Enter
    tmux send-keys -t $SESSION_CODE:3 "cd $OIVAN_PROJECT/sakani-admin" Enter
    tmux send-keys -t $SESSION_CODE:3 "nvim" Enter
    tmux send-keys -t $SESSION_CODE:4 "cd $OIVAN_PROJECT/sakani-partners-frontend" Enter
    tmux send-keys -t $SESSION_CODE:4 "nvim" Enter
    tmux send-keys -t $SESSION_CODE:5 "cd $ELXR_PROJECT/elxr_backend" Enter
    tmux send-keys -t $SESSION_CODE:5 "nvim" Enter

    # SANDBOX
    tmux kill-session -t $SESSION_SANDBOX
    tmux new -d -s $SESSION_SANDBOX -n "golang"

    tmux send-keys -t $SESSION_SANDBOX:1 "cd $DEV_DIR/Golang" Enter
    tmux send-keys -t $SESSION_SANDBOX:1 "nvim" Enter

    # DEVOPS
    tmux kill-session -t $SESSION_DEVOPS
    tmux new -d -s $SESSION_DEVOPS -n "oivan"
    tmux split-window -h -t $SESSION_DEVOPS

    tmux send-keys -t $SESSION_DEVOPS:1.1 "ovpn-up oivan" Enter

    tmux new-window -n "dna"
    tmux send-keys -t $SESSION_DEVOPS:2 "sshadd open_source" Enter
    tmux send-keys -t $SESSION_DEVOPS:2 "ssh dna" Enter

    tmux new-window -n "nvim"
    tmux send-keys -t $SESSION_DEVOPS:3 "cd ~/.config/nvim" Enter
    tmux send-keys -t $SESSION_DEVOPS:3 "nvim" Enter

    tmux -u attach-session -t $SESSION_DEVOPS:1
}
