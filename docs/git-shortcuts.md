# Git Workflow Shortcuts: `gbre`, `gcre`, `gccp`

A trio of shell functions that wrap the Regask git workflow with [`gum`](https://github.com/charmbracelet/gum) prompts so branch creation, commits, and release cherry-picks stay consistent across the team.

| Command | What it does |
|---------|--------------|
| `gbre`  | **g**it **b**ranch (**re**gask) — create a `REG-<ticket>-<slug>` branch |
| `gcre`  | **g**it **c**ommit (**re**gask) — conventional-commit with the ticket auto-detected from the branch |
| `gccp`  | **g**it **c**herry-**p**ick — cherry-pick all `REG-<n>.*` tags onto `release/pre-prod` or `release/prod` and open a PR |

---

## Prerequisites

Install once:

```sh
# macOS (Homebrew)
brew install gum gh

# Linux
# gum: https://github.com/charmbracelet/gum#installation
# gh:  https://github.com/cli/cli#installation

# Authenticate the GitHub CLI (one-time, opens browser)
gh auth login
```

You also need `git` (you have it), and for `gccp` your repo must have an `origin` remote pointing at GitHub plus branches named `release/pre-prod` and `release/prod`.

---

## Installation

### Fish

Drop each file into `~/.config/fish/functions/<name>.fish`. Fish auto-loads them — no `source` needed.

```sh
mkdir -p ~/.config/fish/functions
# then create gbre.fish, gcre.fish, gccp.fish from the snippets below
```

### Zsh

Append the functions to your `~/.zshrc` (or `source` a separate file from there):

```sh
# in ~/.zshrc
source ~/.zsh/git-shortcuts.zsh
```

Then `exec zsh` (or open a new terminal) to pick them up.

---

## `gbre` — create a REG branch

Prompts (with `gum`) for a ticket number and a short description, then runs `git checkout -b REG-<ticket>-<kebab-slug>`. Pass the ticket as `$1` to skip the first prompt. Falls back to `REG-XXXX-...` if no ticket is given.

### Fish — `~/.config/fish/functions/gbre.fish`

```fish
function gbre -d 'new git branch regask'
  set -l TYPE "REG"

  set -l TICKET $argv[1]

  # If Ticket has no value then ask gum
  if test -z $TICKET
    set TICKET $(gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)")
  end

  set -l DESCRIPTION $(gum input --placeholder "Short description of the ticket" | tr '[:upper:]' '[:lower:]' | sed 's/ *$//' | tr ' ' '-')

  # If ticket is empty then set REG-XXXX if not it will be REG-TICKET
  if test -z $TICKET
    git checkout -b "$TYPE-XXXX-$DESCRIPTION"
  else
    git checkout -b "$TYPE-$TICKET-$DESCRIPTION"
  end
end
```

### Zsh

```zsh
gbre() {
  emulate -L zsh
  local TYPE="REG"
  local TICKET="$1"

  if [[ -z $TICKET ]]; then
    TICKET=$(gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)")
  fi

  local DESCRIPTION
  DESCRIPTION=$(gum input --placeholder "Short description of the ticket" \
                 | tr '[:upper:]' '[:lower:]' \
                 | sed 's/ *$//' \
                 | tr ' ' '-')

  if [[ -z $TICKET ]]; then
    git checkout -b "${TYPE}-XXXX-${DESCRIPTION}"
  else
    git checkout -b "${TYPE}-${TICKET}-${DESCRIPTION}"
  fi
}
```

**Example**

```
$ gbre 1234
? Short description of the ticket › Fix Login Race Condition
# => branch: REG-1234-fix-login-race-condition
```

---

## `gcre` — conventional commit with auto-detected ticket

Prompts for a commit type (`fix | feat | docs | style | refactor | test | chore | revert`), extracts the `REG-<id>` from the current branch name, lets you edit the summary, and opens an editor for an optional body.

### Fish — `~/.config/fish/functions/gcre.fish`

```fish
function gcre -d 'git commit regask'
    set -l TYPE $(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

    # Pull REG-<id> out of the current branch name, e.g. REG-1234-foo -> REG-1234
    set -l TICKET $(git rev-parse --abbrev-ref HEAD | string match -r '([A-Z]+-[0-9A-Z]+)' | tail -n 1)
    set -l TICKET (if test -n "$TICKET" ; echo "[$TICKET]" ; end)

    set -l SUMMARY $(gum input --value "$TYPE: $TICKET " --placeholder "Summary of this change")
    set -l DESCRIPTION $(gum write --placeholder "Details of this change (CTRL+D to finish)")

    git commit -m "$SUMMARY" -m "$DESCRIPTION"
end
```

### Zsh

```zsh
gcre() {
  emulate -L zsh
  local TYPE TICKET SUMMARY DESCRIPTION branch

  TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

  branch=$(git rev-parse --abbrev-ref HEAD)
  # Match the LAST REG-<id> in the branch name
  if [[ $branch =~ ([A-Z]+-[0-9A-Z]+) ]]; then
    TICKET="[${match[1]}]"
  else
    TICKET=""
  fi

  SUMMARY=$(gum input --value "${TYPE}: ${TICKET} " --placeholder "Summary of this change")
  DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

  git commit -m "$SUMMARY" -m "$DESCRIPTION"
}
```

**Example**

```
# On branch REG-1234-fix-login
$ gcre
? choose type › fix
? Summary › fix: [REG-1234] guard against null session token
# => commit subject: "fix: [REG-1234] guard against null session token"
```

---

## `gccp` — cherry-pick REG tags to preprod/prod and open a PR

Workflow:

1. Prompts for a REG ticket number (`1234` or `REG-1234`).
2. Prompts for environment: `preprod` (→ base `release/pre-prod`) or `prod` (→ base `release/prod`).
3. `git fetch --tags --prune --force origin <base>` — pulls the latest tags and the latest tip of the release branch.
4. Lists every tag matching `REG-<n>.*` sorted with `sort -V` (so `.001`, `.002`, … apply in order).
5. Confirms with the short SHA of `origin/<base>` so you can see where the branch will be cut from.
6. `git checkout -B cherry-pick-REG-<n>-to-<env> origin/<base>`.
7. `git cherry-pick` each tag in order; bails cleanly on conflict.
8. `git push -u origin <branch>`.
9. `gh pr create --base release/<base> --title "chore: [REG-<n>] cherry pick to <env>" --body "<tag list>"`.

> **Branch protection note:** the script only opens the PR. If your repo requires approvals, that's enforced by GitHub branch protection — not something the script can (or should) bypass. If you want auto-merge once required checks pass, append `&& gh pr merge --auto --squash` to the final line.

### Fish — `~/.config/fish/functions/gccp.fish`

```fish
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
            set base release/pre-prod
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
```

### Zsh

```zsh
gccp() {
  emulate -L zsh
  setopt local_options pipefail

  if ! command -v gum >/dev/null; then
    echo "gccp: gum is required (brew install gum)" >&2
    return 1
  fi
  if ! command -v gh >/dev/null; then
    echo "gccp: gh is required (brew install gh)" >&2
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gccp: not inside a git repository" >&2
    return 1
  fi

  local ticket_input ticket ticket_id env base branch title body base_sha t
  local -a tags body_lines

  ticket_input=$(gum input --header "REG ticket number (e.g. 1234 or REG-1234)" --placeholder "1234")
  if [[ -z $ticket_input ]]; then
    echo "gccp: ticket is required" >&2
    return 1
  fi
  ticket=${ticket_input#REG-}
  ticket_id="REG-${ticket}"

  env=$(gum choose --header "Target environment" preprod prod)
  if [[ -z $env ]]; then
    echo "gccp: environment is required" >&2
    return 1
  fi

  case $env in
    preprod) base="release/pre-prod" ;;
    prod)    base="release/prod" ;;
    *) echo "gccp: unknown environment: $env" >&2; return 1 ;;
  esac

  branch="cherry-pick-${ticket_id}-to-${env}"

  echo "Fetching latest tags and ${base} from origin…"
  git fetch --tags --prune --force origin "$base" || return 1

  tags=("${(@f)$(git tag --list "${ticket_id}.*" | sort -V)}")
  tags=(${tags:#})
  if (( ${#tags[@]} == 0 )); then
    echo "gccp: no tags found matching ${ticket_id}.*" >&2
    return 1
  fi

  echo "Tags to cherry-pick (in order):"
  printf '  - %s\n' "${tags[@]}"

  base_sha=$(git rev-parse --short "origin/${base}")
  if ! gum confirm "Cherry-pick these onto new branch '${branch}' (base: ${base} @ ${base_sha})?"; then
    echo "gccp: aborted"
    return 1
  fi

  git checkout -B "$branch" "origin/${base}" || return 1

  for t in "${tags[@]}"; do
    echo "Cherry-picking ${t}…"
    if ! git cherry-pick "$t"; then
      echo "gccp: cherry-pick failed on ${t} — resolve conflicts then run 'git cherry-pick --continue', and finish the remaining tags manually" >&2
      return 1
    fi
  done

  git push --set-upstream origin "$branch" || return 1

  title="chore: [${ticket_id}] cherry pick to ${env}"
  body_lines=("Cherry-picks the following tags onto \`${base}\`:" "")
  for t in "${tags[@]}"; do
    body_lines+=("- \`${t}\`")
  done
  body=${(F)body_lines}   # join array elements with newlines

  gh pr create --base "$base" --head "$branch" --title "$title" --body "$body"
}
```

**Example**

```
$ gccp
? REG ticket number › 1234
? Target environment › prod
Fetching latest tags and release/prod from origin…
Tags to cherry-pick (in order):
  - REG-1234.001
  - REG-1234.002
  - REG-1234.003
? Cherry-pick these onto new branch 'cherry-pick-REG-1234-to-prod' (base: release/prod @ 8a2f10c)? Yes
…
https://github.com/your-org/your-repo/pull/4567
```

---

## Troubleshooting

- **`gum: command not found`** → `brew install gum`.
- **`gh: command not found`** → `brew install gh`, then `gh auth login`.
- **`gccp: no tags found matching REG-1234.*`** → Tags weren't pushed to `origin`, or the ticket number is wrong. Verify with `git ls-remote --tags origin | grep REG-1234`.
- **Cherry-pick conflict** → resolve the conflict, `git add` the fixed files, `git cherry-pick --continue`, then re-run `gccp` (it will skip already-applied tags? **No** — restart manually from the failed tag onward with `git cherry-pick <next>...<last>`).
- **`gh pr create` fails with "no commits between …"** → the cherry-picks landed nowhere new (tags were already on the base). Confirm `git log origin/<base>..HEAD` shows commits.
- **Wrong base branch** → the script hard-codes `release/pre-prod` and `release/prod`. Edit the `switch` / `case` block to match your repo's conventions.

---

## Quick reference card

| Command                | Inputs                                 | Output                                                                  |
|------------------------|----------------------------------------|-------------------------------------------------------------------------|
| `gbre [ticket]`        | ticket (arg or prompt), description    | new local branch `REG-<ticket>-<slug>`                                  |
| `gcre`                 | type, summary, body                    | commit `<type>: [REG-<id>] <summary>` on current branch                 |
| `gccp`                 | ticket, environment                    | cherry-pick branch + push + PR against `release/pre-prod` or `release/prod` |
