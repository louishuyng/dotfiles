function gccp -d 'cherry-pick REG-<n>.* tags onto release/pre-prod or release/prod and open a PR'
    if not command -q gum
        echo "gccp: gum is required (brew install gum)" >&2
        return 1
    end
    if not command -q gh
        echo "gccp: gh is required (brew install gh)" >&2
        return 1
    end
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "gccp: not inside a git repository" >&2
        return 1
    end

    set -l ticket_input $(gum input --header "REG ticket number (e.g. 1234 or REG-1234)" --placeholder "1234")
    if test -z "$ticket_input"
        echo "gccp: ticket is required" >&2
        return 1
    end
    set -l ticket $(string replace --regex '^REG-' '' -- $ticket_input)
    set -l ticket_id "REG-$ticket"

    set -l env $(gum choose --header "Target environment" preprod prod)
    if test -z "$env"
        echo "gccp: environment is required" >&2
        return 1
    end

    set -l base
    switch "$env"
        case preprod
            set base release/preprod
        case prod
            set base release/prod
        case '*'
            echo "gccp: unknown environment: $env" >&2
            return 1
    end

    set -l branch "cherry-pick-$ticket_id-to-$env"

    echo "Fetching latest tags and $base from origin…"
    git fetch --tags --prune --force origin $base
    or return 1

    set -l tags $(git tag --list "$ticket_id.*" | sort -V)
    if not set -q tags[1]
        echo "gccp: no tags found matching $ticket_id.*" >&2
        return 1
    end

    echo "Tags to cherry-pick (in order):"
    for t in $tags
        echo "  - $t"
    end

    if not gum confirm "Cherry-pick these onto new branch '$branch' (base: $base @ "(git rev-parse --short origin/$base)")?"
        echo "gccp: aborted"
        return 1
    end

    git checkout -B $branch origin/$base
    or return 1

    for t in $tags
        echo "Cherry-picking $t…"
        git cherry-pick $t
        or begin
            echo "gccp: cherry-pick failed on $t — resolve conflicts then run 'git cherry-pick --continue', and finish the remaining tags manually" >&2
            return 1
        end
    end

    git push --set-upstream origin $branch
    or return 1

    set -l title "chore: [$ticket_id] cherry pick to $env"

    set -l body_lines "Cherry-picks the following tags onto \`$base\`:" ""
    for t in $tags
        set -a body_lines "- \`$t\`"
    end
    set -l body $(string join \n -- $body_lines)

    gh pr create --base $base --head $branch --title $title --body $body
end
