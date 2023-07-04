if status is-interactive
  # FIX: set default key bindings fixing https://stackoverflow.com/a/41905020
  set -U fish_key_bindings fish_default_key_bindings

  set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

  source ~/.dotfiles/terminals/fish/alias/init.fish
  source ~/.dotfiles/terminals/fish/env/init.fish

  starship init fish | source

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
  complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end
