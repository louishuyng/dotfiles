#!/bin/bash
# brew install gh && gh auth login
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
DIR=$(cat "$CWD_FILE" 2>/dev/null)
{ [ -d "$DIR" ] && command -v gh >/dev/null && git -C "$DIR" rev-parse >/dev/null 2>&1; } || { sketchybar --set ci drawing=off; exit 0; }
cd "$DIR" || exit 0

R=$(gh run list -L1 --branch "$(git branch --show-current)" --json conclusion,number,url -q '.[0] | "\(.conclusion)\t\(.number)\t\(.url)"' 2>/dev/null)
IFS=$'\t' read -r CONCL NUM URL <<<"$R"
{
  [ -n "$URL" ] && printf 'run\topen last run\t%s\topen '"'"'%s'"'"'\n' "$ERR" "$URL"
  gh pr list -L 8 --json number,title,url -q '.[] | "#\(.number)\t\(.title)\t\t open '"'"'\(.url)'"'"'"' 2>/dev/null
} | popup_rows ci CI
if [ "$CONCL" = "failure" ]; then sketchybar --set ci drawing=on label="ci ✗ #$NUM"
else sketchybar --set ci drawing=off; fi
