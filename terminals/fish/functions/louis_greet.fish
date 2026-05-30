function _louis_row
    set -l key $argv[1]
    set -e argv[1]
    set -l sep (printf '\e[38;5;240m · \e[38;5;255m')
    set -l value (string join $sep -- $argv)
    printf '   \e[38;5;41m▸\e[0m \e[1;38;5;246m%-9s\e[0m \e[38;5;255m%s\e[0m\n' $key $value
end

function _louis_uptime
    set -l boot (sysctl -n kern.boottime 2>/dev/null | string match -rg 'sec = (\d+)')
    if test -z "$boot"
        echo '?'
        return
    end
    set -l secs (math (date +%s) - $boot)
    set -l d (math --scale=0 $secs / 86400)
    set -l h (math --scale=0 "($secs % 86400) / 3600")
    set -l m (math --scale=0 "($secs % 3600) / 60")
    if test $d -gt 0
        printf '%sd %sh\n' $d $h
    else if test $h -gt 0
        printf '%sh %sm\n' $h $m
    else
        printf '%sm\n' $m
    end
end

function _louis_git_info
    git -C $PWD rev-parse --is-inside-work-tree >/dev/null 2>&1; or return 1
    basename (git -C $PWD rev-parse --show-toplevel)
    set -l branch (git -C $PWD symbolic-ref --short HEAD 2>/dev/null)
    test -z "$branch"; and set branch (git -C $PWD rev-parse --short HEAD)
    echo $branch
    set -l dirty (git -C $PWD status --porcelain | count)
    test $dirty -gt 0; and echo "$dirty dirty"
end

function _louis_quote
    set -l quotes \
        "The sky above the port was the color of television, tuned to a dead channel. — Gibson" \
        "Hello, friend. Hello, friend? That's lame. — Mr. Robot" \
        "Net is vast and infinite. — Ghost in the Shell" \
        "I never asked for this. — Adam Jensen" \
        "The street finds its own uses for things. — Gibson" \
        "Reality is a thing of the past. — Snow Crash" \
        "All those moments will be lost in time, like tears in rain. — Blade Runner" \
        "Cyberspace. A consensual hallucination experienced daily by billions. — Neuromancer" \
        "Wake up, Samurai. We have a city to burn. — Cyberpunk 2077" \
        "What if everything you see is more than what you see? — Ghost in the Shell" \
        "Information wants to be free. — Stewart Brand" \
        "The future is already here — it's just not very evenly distributed. — Gibson"

    set -l n (count $quotes)
    set -l idx (math (random) % $n + 1)
    set -l text $quotes[$idx]

    set -l cols $COLUMNS
    test -z "$cols"; and set cols 80
    set -l max (math $cols - 8)

    set -l words (string split ' ' -- $text)
    set -l line ''
    set -l out
    for w in $words
        if test (string length -- "$line $w") -gt $max
            set out $out $line
            set line $w
        else if test -z "$line"
            set line $w
        else
            set line "$line $w"
        end
    end
    test -n "$line"; and set out $out $line

    for l in $out
        printf ' \e[38;5;240m\e[0m \e[3;38;5;247m%s\e[0m \e[38;5;240m\e[0m\n' $l
    end
end

function louis_greet --description 'Cyberpunk LOUIS start page'
    set -l art \
        '██╗      ██████╗ ██╗   ██╗██╗███████╗' \
        '██║     ██╔═══██╗██║   ██║██║██╔════╝' \
        '██║     ██║   ██║██║   ██║██║███████╗' \
        '██║     ██║   ██║██║   ██║██║╚════██║' \
        '███████╗╚██████╔╝╚██████╔╝██║███████║' \
        '╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚══════╝'

    # GitHub contributor-graph greens, bright mint → deep forest
    set -l grad 48 41 41 35 35 29

    echo
    for i in (seq (count $art))
        printf '  \e[38;5;%sm%s\e[0m\n' $grad[$i] $art[$i]
    end
    echo

    set -l u (uname -srm | string split ' ')
    _louis_row kernel "$u[1] $u[2]" $u[3]
    _louis_row session (prompt_hostname) "fish $FISH_VERSION" "up "(_louis_uptime)

    set -l repo_info (_louis_git_info)
    if test -n "$repo_info"
        _louis_row repo $repo_info
    end

    echo
    _louis_quote
    echo
end
