function tm-logger -d 'open latest tmux show latest capture logger'
  nvim '+$' /tmp/(ls --sort created /tmp | grep tmux | tail -1 | awk '{print $7}')
end
