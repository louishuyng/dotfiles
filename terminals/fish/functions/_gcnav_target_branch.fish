function _gcnav_target_branch -d 'Resolve the target branch used by gcnext (saves current branch when attached)'
    set -l current_branch (git symbolic-ref --short -q HEAD)
    if test -n "$current_branch"
        set -g _GCNAV_TARGET $current_branch
        echo $current_branch
        return 0
    end

    if set -q _GCNAV_TARGET
        if git rev-parse --verify "$_GCNAV_TARGET" >/dev/null 2>&1
            echo $_GCNAV_TARGET
            return 0
        end
    end

    set -l fallback (git for-each-ref --contains HEAD --format='%(refname:short)' refs/heads/ | head -n 1)
    if test -n "$fallback"
        set -g _GCNAV_TARGET $fallback
        echo $fallback
        return 0
    end

    return 1
end
