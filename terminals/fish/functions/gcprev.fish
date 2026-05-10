function gcprev -d 'Move HEAD to its parent commit; checkout the branch if one points there'
    set -l parent (git rev-parse --verify HEAD^ 2>/dev/null)
    if test -z "$parent"
        echo "gcprev: no parent commit"
        return 1
    end

    set -l current_branch (git symbolic-ref --short -q HEAD)
    if test -n "$current_branch"
        set -g _GCNAV_TARGET $current_branch
    end

    _gcnav_checkout $parent
end
