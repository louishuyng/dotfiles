function _gcnav_checkout -d 'Checkout a commit, preferring a local branch that points at it'
    set -l sha $argv[1]
    if test -z "$sha"
        return 1
    end

    set -l branch (git for-each-ref --format='%(refname:short)' --points-at=$sha refs/heads/ | head -n 1)

    if test -n "$branch"
        git checkout $branch
    else
        git -c advice.detachedHead=false checkout --detach $sha
    end
end
