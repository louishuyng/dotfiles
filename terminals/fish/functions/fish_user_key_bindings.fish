function fish_user_key_bindings
  fish_vi_key_bindings
  fzf_bindings
  custom_bindings
end

function fzf_bindings
  fzf_configure_bindings --directory=\cf --git_log=\cg
end

function custom_bindings
  bind \cn 'clear; nvim'
  bind \e\e 'thefuck-command-line'
end
