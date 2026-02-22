function p-clean -d 'clean all major processes'
    set -l array node ruby k9s nvim gopls claude prettierd opencode

    for element in $array
        if pkill -9 -f $element >/dev/null 2>&1
            echo "Successfully killed $element"
        else
            echo "No running $element processes"
        end
    end

    brew services stop postgresql@15
    echo "Successfully stopped postgresql@15"
end
