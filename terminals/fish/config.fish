if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fisher_path ~/.dotfiles/terminals/fish/fisherman

source ~/.dotfiles/terminals/fish/alias/init.fish
source ~/.dotfiles/terminals/fish/env/init.fish

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
