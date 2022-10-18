function louisws -d "working space of louis"
    set -l DEV_DIR "~/Dev/Projects"
    set -l ORG_DIR "~/Dev/org/"

    set -l PERX $DEV_DIR/PerxTech
    set -l PDP $DEV_DIR/Productpine

    set -l SESSION_ORG "Workflow"
    set -l SESSION_DEV "Dev"
    set -l SESSION_SERVER "Server"

    # Org
    tmux kill-session -t $SESSION_ORG

    tmux new -d -s $SESSION_ORG -n "work"
    tmux send-keys -t $SESSION_ORG:1 "cd $ORG_DIR/work" Enter
    tmux send-keys -t $SESSION_ORG:1 "clear" Enter
    tmux send-keys -t $SESSION_ORG:1 "nv index.norg" Enter

    tmux new-window -n "life"
    tmux send-keys -t $SESSION_ORG:2 "cd $ORG_DIR/life" Enter
    tmux send-keys -t $SESSION_ORG:2 "clear" Enter
    tmux send-keys -t $SESSION_ORG:2 "nv index.norg" Enter

    tmux new-window -n "config"
    tmux send-keys -t $SESSION_ORG:3 "cd ~/.dotfiles" Enter
    tmux send-keys -t $SESSION_ORG:3 "nv" Enter

    # DEV
    tmux kill-session -t $SESSION_DEV
    tmux new -d -s $SESSION_DEV -n "perx-api"
    tmux send-keys -t $SESSION_DEV:1 "cd $PERX/perx-api" Enter
    tmux send-keys -t $SESSION_DEV:1 "clear" Enter
    tmux send-keys -t $SESSION_DEV:1 "nv" Enter

    tmux new-window -n "bms"
    tmux send-keys -t $SESSION_DEV:2 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_DEV:2 "clear" Enter
    tmux send-keys -t $SESSION_DEV:2 "nv" Enter

    # System
    tmux kill-session -t $SESSION_SERVER

    tmux new -d -s $SESSION_SERVER -n "PerxTech-Docker"
    tmux send-keys -t $SESSION_SERVER:1 "cd $PERX/perx-api" Enter
    tmux send-keys -t $SESSION_SERVER:1 "clear" Enter
    tmux send-keys -t $SESSION_SERVER:1 "dce app bash" Enter
    tmux send-keys -t $SESSION_SERVER:1 "clear" Enter

    tmux new-window -n "PDP-Herouku"
    tmux split-window -h

    tmux send-keys -t $SESSION_SERVER:2.1 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_SERVER:2.1 "c" Enter
    tmux send-keys -t $SESSION_SERVER:2.1 "staging console"

    tmux send-keys -t $SESSION_SERVER:2.2 "cd $PDP/brand-management-system" Enter
    tmux send-keys -t $SESSION_SERVER:2.2 "c" Enter
    tmux send-keys -t $SESSION_SERVER:2.2 "production console"

    tmux -u attach-session -t $SESSION_ORG:1
end
