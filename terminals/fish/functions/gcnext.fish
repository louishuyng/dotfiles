function gcnext -d 'Move HEAD to the next commit toward the target branch; checkout the branch at its tip'
    set -l target (_gcnav_target_branch)
    if test -z "$target"
        echo "gcnext: no target branch (set _GCNAV_TARGET or check out a branch first)"
        return 1
    end

    set -l current (git rev-parse HEAD)
    set -l target_sha (git rev-parse --verify "$target" 2>/dev/null)
    if test -z "$target_sha"
        echo "gcnext: target branch '$target' not found"
        return 1
    end

    if test "$current" = "$target_sha"
        echo "gcnext: already at tip of $target"
        return 0
    end

    set -l next (git rev-list --topo-order --reverse --first-parent "$current..$target" | head -n 1)
    if test -z "$next"
        echo "gcnext: HEAD is not an ancestor of $target"
        return 1
    end

    _gcnav_checkout $next
end
