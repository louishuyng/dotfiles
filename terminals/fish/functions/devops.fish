function devops -d "Run Devops Container Efficiently"
  set -l context $argv[1];

  echo "Running on Context: $context"
  echo "Running services: $argv[2..-1]"

  docker-compose -f ~/.dotfiles/devops/docker-compose-$argv[1].yaml up $argv[2..-1]
end
