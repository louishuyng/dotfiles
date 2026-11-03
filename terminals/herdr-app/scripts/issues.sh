#!/bin/bash
# issues.sh — my open GitHub PRs and the active Jira sprint, as one JSON shape for the
# `issues` mod. Each source logs in through its own CLI; no tokens live here:
#   GitHub: `gh auth login`
#   Jira:   `acli jira auth login --web`
#
#   issues.sh list                          {items: [...], errors: [{source, message}]}
#   issues.sh assign <source> <id>          assign to me
#   issues.sh move <source> <id> <status>   move a Jira work item to a status
#
# Item: {source, id, key, group, kind, title, url, status, reasons, labels, author, assignee,
#        mine, sprint, updated}
set -euo pipefail

SOURCES=(github jira)

# --- GitHub -------------------------------------------------------------------------------

# Open PRs I created, was asked to review, or was assigned, plus my PRs whose checks fail.
# A PR found by several searches appears once, with every search in `reasons`.
github_list() {
  local me fields='number,title,repository,assignees,author,updatedAt,url,labels,isDraft'
  me=$(gh api user --jq .login)
  search() { gh search prs --state=open --limit 100 --json "$fields" "${@:2}" | jq --arg r "$1" 'map(. + {reason: $r})'; }
  {
    search ci --author=@me --checks=failure
    search review --review-requested=@me
    search assigned --assignee=@me
    search created --author=@me
  } | jq -s --arg me "$me" 'add | group_by(.url) | map(.[0] + {reasons: map(.reason)}) | map({
      source: "github",
      id: "\(.repository.nameWithOwner)#\(.number)",
      key: "#\(.number)",
      group: .repository.name,
      kind: "pr",
      title,
      url,
      status: (if .isDraft then "draft" else "open" end),
      reasons,
      labels: [.labels[].name],
      author: .author.login,
      assignee: (.assignees[0].login // null),
      mine: any(.assignees[]; .login == $me),
      sprint: null,
      updated: .updatedAt
    })'
}

github_assign() {
  gh pr edit "${1##*#}" --repo "${1%#*}" --add-assignee @me >/dev/null
}

# --- Jira ---------------------------------------------------------------------------------

jira_auth() { acli jira auth status | sed -n "s/^ *$1: //p"; }

JIRA_BOARD=145

# Every work item in the board's active sprint, the whole team's, like the board itself.
# acli returns no `updated` field: items keep the sprint's order and carry no age.
jira_list() {
  local me site sprint
  me=$(jira_auth Email)
  site=$(jira_auth Site)
  sprint=$(acli jira board list-sprints --id "$JIRA_BOARD" --state active --json | jq -c '.sprints[0] // empty')
  [ -n "$sprint" ] || { echo "board $JIRA_BOARD has no active sprint" >&2; return 1; }
  acli jira sprint list-workitems --board "$JIRA_BOARD" --sprint "$(jq -r .id <<<"$sprint")" \
    --json --paginate --limit 500 --fields "key,summary,status,assignee,reporter,labels,issuetype" |
    jq -s --arg me "$me" --arg site "$site" --argjson sprint "$sprint" '[.[].issues[]] | map({
      source: "jira",
      id: .key,
      key: .key,
      group: (.key | split("-")[0]),
      kind: (.fields.issuetype.name | ascii_downcase),
      title: .fields.summary,
      url: "https://\($site)/browse/\(.key)",
      status: .fields.status.name,
      reasons: [],
      labels: (.fields.labels // []),
      author: (.fields.reporter.displayName // null),
      assignee: (.fields.assignee.displayName // null),
      mine: (.fields.assignee.emailAddress == $me),
      sprint: $sprint.name,
      updated: null
    })'
}

jira_assign() {
  acli jira workitem assign --key "$1" --assignee @me --yes >/dev/null
}

jira_move() {
  acli jira workitem transition --key "$1" --status "$2" --yes >/dev/null
}

# --- Commands -----------------------------------------------------------------------------

list() {
  local tmp source pids=()
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  for source in "${SOURCES[@]}"; do
    { "${source}_list" >"$tmp/$source.json" 2>"$tmp/$source.err" || echo '[]' >"$tmp/$source.json"; } &
    pids+=($!)
  done
  wait "${pids[@]}"
  for source in "${SOURCES[@]}"; do
    # A source that printed partial output before failing still counts as failed.
    jq -e 'type == "array"' "$tmp/$source.json" >/dev/null 2>&1 || echo '[]' >"$tmp/$source.json"
    [ -s "$tmp/$source.err" ] || continue
    sed -i '' -E 's/^.*line [0-9]+: //' "$tmp/$source.err"
    jq -n --arg s "$source" --rawfile m "$tmp/$source.err" '{source: $s, message: ($m | rtrimstr("\n"))}' >"$tmp/$source.error"
  done
  shopt -s nullglob
  local errors=("$tmp"/*.error)
  # Undated items (Jira) sort after dated ones, keeping their own order.
  jq -s '{items: (add | (map(select(.updated)) | sort_by(.updated) | reverse) + map(select(.updated | not)))}' "$tmp"/*.json |
    jq --argjson errors "$(cat /dev/null ${errors[@]+"${errors[@]}"} | jq -s .)" '. + {errors: $errors}'
}

case "${1:-}" in
  list) list ;;
  assign | move)
    if ! declare -F "${2:-}_$1" >/dev/null; then
      echo "${2:-?} cannot $1" >&2
      exit 2
    fi
    "${2}_$1" "${@:3}"
    ;;
  *) echo "usage: issues.sh list | assign <source> <id> | move <source> <id> <status>" >&2; exit 2 ;;
esac
