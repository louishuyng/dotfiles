function tm-cap -d 'tmux capture logging'
  tmux capture-pane -pS -1000000 > /tmp/tmux_(date +%Y%m%d_%H%M%S) && nvim '+$' /tmp/(ls --sort created /tmp | grep tmux | tail -1 | awk '{print $7}')
end
