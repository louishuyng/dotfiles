function pg-c -d 'connect postgres locally using pgcli'
  set -l host $argv[1]
  set -l database $argv[2]

  if [ -z $host ]
    pgcli -h localhost -p 5432 -U postgres
  else if [ -z $database ]
    pgcli -h localhost -p 5432 -U $host
  else
    pgcli -h localhost -p 5432 -U $host $database
  end
end

