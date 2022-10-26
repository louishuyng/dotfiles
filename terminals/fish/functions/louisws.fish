function louisws -d "working space of louis"
    set -l DEV_DIR "~/Dev/Projects"
    set -l ORG_DIR "~/Dev/org/"

    set -l PERX $DEV_DIR/PerxTech
    set -l PDP $DEV_DIR/Productpine

    set -l SESSION_ORG "Workflow"
    set -l SESSION_PERX "Perx"
    set -l SESSION_PDP "Pdp"

    # Workflow
    tmux kill-session -t $SESSION_ORG

    tmux new -d -s $SESSION_ORG -n "org"
    tmux send-keys -t $SESSION_ORG:1 "cd $ORG_DIR/work" Enter
    tmux send-keys -t $SESSION_ORG:1 "clear" Enter
    tmux send-keys -t $SESSION_ORG:1 "nv index.norg" Enter

    tmux new-window -n "dotfile"
    tmux send-keys -t $SESSION_ORG:2 "cd ~/.dotfiles" Enter
    tmux send-keys -t $SESSION_ORG:2 "clear" Enter
    tmux send-keys -t $SESSION_ORG:2 "nv" Enter

    # PERX
    tmux kill-session -t $SESSION_PERX

    ## API
    tmux new -d -s $SESSION_PERX -n "perx-api"
    tmux send-keys -t $SESSION_PERX:1 "cd $PERX/perx-api" Enter
    tmux send-keys -t $SESSION_PERX:1 "clear" Enter
    tmux send-keys -t $SESSION_PERX:1 "nv" Enter

    ## ETL
    tmux new-window -n "etl"
    tmux send-keys -t $SESSION_PERX:2 "cd $PERX/etl-perx" Enter
    tmux send-keys -t $SESSION_PERX:2 "clear" Enter
    tmux send-keys -t $SESSION_PERX:2 "nv" Enter


    ## DASHBOARD
    tmux new-window -n "dashboard"
    tmux send-keys -t $SESSION_PERX:3 "cd $PERX/perx-dashboard-v4" Enter
    tmux send-keys -t $SESSION_PERX:3 "clear" Enter
    tmux send-keys -t $SESSION_PERX:3 "yarn start-local"

    ## MICROSITE
    tmux new-window -n "microsite"
    tmux split-window -h

    tmux send-keys -t $SESSION_PERX:4.1 "cd $PERX/microsite-apps-ng" Enter
    tmux send-keys -t $SESSION_PERX:4.1 "clear" Enter
    tmux send-keys -t $SESSION_PERX:4.1 "yarn start:server"

    tmux send-keys -t $SESSION_PERX:4 "cd $PERX/microsite-apps-ng" Enter
    tmux send-keys -t $SESSION_PERX:4.2 "clear" Enter
    tmux send-keys -t $SESSION_PERX:4.2 "yarn start:blackcomb:staging"

    # Product pine
    tmux kill-session -t $SESSION_PDP

    ## BMS
    tmux new -d -s $SESSION_PDP -n "bms"
    tmux send-keys -t $SESSION_PDP:1 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_PDP:1 "clear" Enter
    tmux send-keys -t $SESSION_PDP:1 "nv" Enter

    ## HEROKU
    tmux new-window -n "servers"
    tmux split-window -h

    tmux send-keys -t $SESSION_PDP:2.1 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_PDP:2.1 "c" Enter
    tmux send-keys -t $SESSION_PDP:2.1 "staging console"

    tmux send-keys -t $SESSION_PDP:2.2 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_PDP:2.2 "c" Enter
    tmux send-keys -t $SESSION_PDP:2.2 "production console"

    tmux -u attach-session -t $SESSION_ORG:1
end
