function docker-compose-up -d "Starts the docker-compose service by name of the service"
  set -l service_name $argv[1]
  set -l service_path (cat ~/.dotfiles/config/docker-compose/name-to-path.txt | grep $service_name | awk '{print $2}')

  # Remove the path ~/ and replace with /Users/username/
  set -l service_path (echo $service_path | sed 's/~/\/Users\/'$USER'/')

  docker-compose -f $service_path up -d
end
