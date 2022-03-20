function fish_user_key_bindings
  fzf_bindings
  common_bindings
  thefuck_bindings
end

function fzf_bindings
  fzf_configure_bindings --directory=\cf
end

function common_bindings -d 'common bindings relevant to terminal interact'
  bind \cl 'clear; commandline -f repaint'
end

function thefuck_bindings
  bind \e\e 'thefuck-command-line'
end
