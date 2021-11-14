function dev() {
  str="$*"
  tmux -u new -s $str
}

function codeSpace () {
    DEV_DIR="~/Dev/Projects"

    OIVAN_PROJECT="$DEV_DIR/Oivan/sakani-workspace"
    ELXR_PROJECT="$DEV_DIR/ELXR"
    JHMSU_PROJECT="$DEV_DIR/Jhmsu"

    SESSION_OIVAN='Oivan'
    SESSION_ELXR='Elxr'
    SESSION_JHMSU='Jhmsu'
    SESSION_DEVOPS='Devops'
    SESSION_SANDBOX='Sandbox'

    # OIVAN
    tmux kill-session -t $SESSION_OIVAN
    tmux new -d -s $SESSION_OIVAN -n "api"
    tmux new-window -n "market"
    tmux new-window -n "v3-fe"
    tmux new-window -n "admin-fe"
    tmux new-window -n "sapa-fe"

    tmux send-keys -t $SESSION_OIVAN:1 "nvim ~/vimwiki/Oivan-API.wiki" Enter
    tmux send-keys -t $SESSION_OIVAN:2 "cd $OIVAN_PROJECT/sakani-market-units-service" Enter
    tmux send-keys -t $SESSION_OIVAN:2 "nvim" Enter
    tmux send-keys -t $SESSION_OIVAN:3 "cd $OIVAN_PROJECT/sakani-v3-frontend" Enter
    tmux send-keys -t $SESSION_OIVAN:3 "nvim" Enter
    tmux send-keys -t $SESSION_OIVAN:4 "cd $OIVAN_PROJECT/sakani-admin" Enter
    tmux send-keys -t $SESSION_OIVAN:4 "nvim" Enter
    tmux send-keys -t $SESSION_OIVAN:5 "cd $OIVAN_PROJECT/sakani-partners-frontend" Enter
    tmux send-keys -t $SESSION_OIVAN:5 "nvim" Enter

    # ELXR
    tmux kill-session -t $SESSION_ELXR
    tmux new -d -s $SESSION_ELXR -n "api"
    tmux new-window -n "backend"
    tmux send-keys -t $SESSION_ELXR:1 "nvim ~/vimwiki/Elxr-API.wiki" Enter
    tmux send-keys -t $SESSION_ELXR:2 "cd $ELXR_PROJECT/elxr_backend" Enter
    tmux send-keys -t $SESSION_ELXR:2 "nvim" Enter

    # JHMSU
    tmux kill-session -t $SESSION_JHMSU
    tmux new -d -s $SESSION_JHMSU -n "api"
    tmux new-window -n "dentist-be"
    tmux new-window -n "dentist-fe"

    tmux send-keys -t $SESSION_JHMSU:1 "nvim ~/vimwiki/Dentist-API.wiki" Enter
    tmux send-keys -t $SESSION_JHMSU:2 "cd $JHMSU_PROJECT/dentist-backend" Enter
    tmux send-keys -t $SESSION_JHMSU:2 "nvim" Enter
    tmux send-keys -t $SESSION_JHMSU:3 "cd $JHMSU_PROJECT/dentist" Enter
    tmux send-keys -t $SESSION_JHMSU:3 "nvim" Enter

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

    tmux new-window -n "top"
    tmux send-keys -t $SESSION_DEVOPS:4 "top" Enter

    tmux -u attach-session -t $SESSION_DEVOPS:1
}
