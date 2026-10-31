function kill-port -d 'Stop processes listening on a TCP port'
    if test (count $argv) -ne 1; or not string match -rq '^[0-9]{1,5}$' -- "$argv[1]"; or test "$argv[1]" -lt 1; or test "$argv[1]" -gt 65535
        echo 'Usage: kill-port <port-number> (1-65535)' >&2
        return 2
    end

    if not command -q lsof
        echo 'kill-port: lsof is required' >&2
        return 1
    end

    set -l pids (command lsof -nP -t -iTCP:$argv[1] -sTCP:LISTEN)
    if not set -q pids[1]
        echo "No TCP listener found on port $argv[1]"
        return 0
    end

    command kill -TERM $pids
    or return $status

    echo "Sent SIGTERM to TCP port $argv[1] listener(s): $pids"
end
