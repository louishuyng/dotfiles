function fish_user_key_bindings
  # peco
  bind \cr peco_select_history # Bind for peco select history to Ctrl+R
  bind \cf peco_change_directory # Bind for peco change directory to Ctrl+F

  # vim-like
  bind \cl forward-char

  # prevent iterm2 from closing when typing Ctrl-D (EOF)
  bind \cd delete-char
end

function b64
  cat $1 | base64 | pbcopy;
end

function sshadd
  ssh-add -D

  if test "$argv[1]" = null
    ssh-add -K ~/.ssh/id_rsa
  else
    ssh-add -K ~/.ssh/id_rsa_$name
  end
end

function Dev
  tm new -s $argv
end
