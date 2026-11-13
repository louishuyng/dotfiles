function _louis_prompt
    printf '\e[1;38;5;29m%s@%s\e[0m:~$ \e[1;38;5;41m%s\e[0m\n' $USER (prompt_hostname) "$argv"
end

# args: number, title, then key/value pairs
function _louis_section
    printf ' \e[38;5;244m%s |\e[0m \e[1;38;5;29m:: %s\e[0m\n' $argv[1] $argv[2]
    set -e argv[1..2]
    set -l n (count $argv)
    for i in (seq 1 2 $n)
        set -l branch '├──'
        test $i -ge (math $n - 1); and set branch '└──'
        printf '    \e[38;5;244m%s\e[0m \e[1;38;5;35m%-8s\e[0m %s\n' $branch $argv[$i] $argv[(math $i + 1)]
    end
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
        printf '    \e[3;38;5;244m# %s\e[0m\n' $l
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

    # phosphor greens, bright mint → deep forest
    set -l grad 48 41 35 34 28 22

    echo
    _louis_prompt cat profile.ansi
    set -l u (uname -srm | string split ' ')
    set -l banner
    for i in (seq (count $art))
        # solid blocks in the terminal foreground, shadow outline in the gradient
        set -l blocks (printf '\e[39m$1\e[38;5;%sm' $grad[$i])
        set -a banner (printf '\e[38;5;%sm%s\e[0m' $grad[$i] (string replace -ra '(█+)' $blocks -- $art[$i]))
    end
    set -a banner (printf '%s / \e[38;5;35m@%s\e[0m' $USER (prompt_hostname))
    set -a banner "fish $FISH_VERSION / $u[1] $u[3]"

    # regenerate from the GitHub avatar:
    #   magick avatar.png -colorspace Gray -level 15%,75% g.png
    #   chafa --format symbols --symbols braille --colors none --bg white --fg black --size 32x16 g.png
    set -l avatar (cat $__fish_config_dir/assets/louis_avatar.ansi 2>/dev/null)
    if test (count $avatar) -gt 0 -a "$COLUMNS" -ge 74
        set -l top (math --scale=0 "("(count $avatar)" - "(count $banner)") / 2")
        for i in (seq (count $avatar))
            set -l j (math $i - $top)
            set -l right ''
            test $j -ge 1 -a $j -le (count $banner); and set right $banner[$j]
            set -l c $grad[(math --scale=0 "ceil($i * "(count $grad)" / "(count $avatar)")")]
            printf '  \e[38;5;%sm%s\e[0m  %s\n' $c $avatar[$i] $right
        end
    else
        printf '  %s\n' $banner
    end
    echo

    _louis_prompt cat session.status
    _louis_section 01 SYSTEM kernel "$u[1] $u[2]" arch $u[3] shell "fish $FISH_VERSION" uptime (_louis_uptime)

    set -l repo_info (_louis_git_info)
    if test -n "$repo_info"
        set -l state clean
        set -q repo_info[3]; and set state $repo_info[3]
        _louis_section 02 REPO name $repo_info[1] branch $repo_info[2] state $state
    end
    _louis_quote
    echo
end
