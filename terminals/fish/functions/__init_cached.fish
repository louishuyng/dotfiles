# Shell-integration generators (`starship init fish`, `zoxide init fish`, ...) cost
# 10-30ms of subprocess each and their output only changes when the tool is upgraded,
# so cache the generated script keyed on the binary's mtime.
#
# This caches the *text*, not its effects: commands written into the generated script
# (`atuin uuid`, `mise hook-env`) still run on every shell, so per-session behaviour is
# unchanged. A tool upgrade bumps its mtime and the cache regenerates itself.
#
# Caveat: only the binary is part of the cache key. Some generators also read env vars
# or config (atuin honours $ATUIN_NOBIND) — after changing one of those, clear the
# cache with `rm -rf $__fish_cache_dir/init`.
function __init_cached --description 'source a tool init script, regenerating only when the binary changes'
    set -l bin $argv[1]
    set -l sub $argv[2..]

    set -l exe (command -v $bin)
    or return 0

    # path mtime needs fish 3.5+; fall back to generating live rather than guessing.
    set -l mtime (builtin path mtime $exe 2>/dev/null)
    if test -z "$mtime"
        $exe $sub | source
        return
    end

    set -l cache $__fish_cache_dir/init
    set -l file $cache/$bin-$mtime.fish

    if not test -s $file
        set -l tmp $file.$fish_pid.tmp
        command mkdir -p $cache
        if $exe $sub >$tmp 2>/dev/null; and test -s $tmp
            command rm -f $cache/$bin-*.fish
            command mv -f $tmp $file
        else
            command rm -f $tmp
            $exe $sub | source
            return
        end
    end

    source $file
end
