function pg-connect -d 'connect postgres locally using pgcli'
  set -l database $argv[2]

  if [ -z $database ]
    pgcli -h localhost -p 5432 -U $argv[1]
  else
    pgcli -h localhost -p 5432 -U $argv[1] $argv[2]
  end
end
