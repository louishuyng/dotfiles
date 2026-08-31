#!/opt/homebrew/bin/bash
# Agent attention tracker: which pane is working, which is blocked on you, and
# which finished while you were looking somewhere else.
#
# Polls pane contents from the status bar rather than wiring Claude's
# PreToolUse/PostToolUse hooks (which fork per tool call — see plans/004), and
# it also covers codex/opencode panes, which have no hook system.
#
# ponytail: screen-scraping heuristic; if the markers below stop matching a
# future Claude TUI, swap scan() for hook-written state files.
set -uo pipefail

SCRIPT="$(realpath "$0")"

# Nerd Font Material Design icons, the same set the rest of the status bar
# uses. Written as escapes, not literal glyphs: private-use codepoints do not
# survive every editor and pipe, and a silently emptied icon looks like a
# missing font rather than a mangled file.
ICON_BUSY=$'\U000F051F'      # timer-sand
ICON_BLOCKED=$'\U000F0026'   # alert
ICON_DONE=$'\U000F012C'      # check
ICON_IDLE=$'\U000F09DE'      # circle-small

AGENT_RE='^(claude|codex|opencode|aider|crush)$'

# Working: fullscreen TUI shows an elapsed timer ("… (1m 14s · ↓ 4.1k tokens)");
# the inline TUI shows "esc to interrupt".
BUSY_RE='esc to interrupt|[0-9]+s · '
BLOCKED_RE='Do you want|Allow this tool'

STATE="${TMPDIR:-/tmp}/tmux-agent-state"
TERM_APPS='Ghostty|WezTerm|Alacritty|kitty|Terminal|iTerm2|Neovide'

# watching → the pane on screen is really in front of you, i.e. a terminal is
# also the frontmost app. Without this, tabbing to a browser while an agent
# works would count as watching it, and nothing would ever alert.
#
# lsappinfo, not osascript: the AppleScript route needs Automation consent and
# blocks on the consent dialog — fatal inside a 2s status poll.
watching() {
  [[ $(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null) =~ $TERM_APPS ]]
}

# notify <pane> <label> <state> — fire and forget, one banner per pane.
# Detached because terminal-notifier can block (it hangs outright on -sender),
# and the status bar must never wait on it.
notify() {
  command -v terminal-notifier >/dev/null 2>&1 || return 0
  local pane=$1 label=$2 icon msg sound
  case $3 in
    # Two distinct tones: you can tell "come approve this" from "it's done"
    # without looking. Names come from /System/Library/Sounds.
    blocked) icon=$ICON_BLOCKED; msg='waiting for your approval'; sound=Ping ;;
    done)    icon=$ICON_DONE;    msg='finished';                  sound=Glass ;;
    *) return 0 ;;
  esac
  # Clicking the banner jumps straight to the pane that raised it.
  ( timeout 10 terminal-notifier -group "agent-$pane" \
      -title "$icon $label" -message "$msg" -sound "$sound" \
      -execute "$SCRIPT --focus $pane" >/dev/null 2>&1 & ) &
}

unnotify() {
  command -v terminal-notifier >/dev/null 2>&1 || return 0
  ( timeout 10 terminal-notifier -remove "agent-$1" >/dev/null 2>&1 & ) &
}

# scan → TSV: pane_id, state (busy|blocked|done|idle), label
# `done` is an edge, not a screen marker, so it is the one thing carried across
# ticks in $STATE. A pane you are actually watching is never done/blocked.
scan() {
  local -A prev=()
  local id st
  if [[ -r $STATE ]]; then
    while read -r id st; do prev[$id]=$st; done < "$STATE"
  fi

  local seen_ok=1
  watching || seen_ok=0

  local tmp="$STATE.$$"
  : > "$tmp"

  local pane cmd label onscreen screen state was
  while IFS='|' read -r pane cmd label onscreen; do
    [[ $cmd =~ $AGENT_RE ]] || continue
    screen=$(tmux capture-pane -p -t "$pane" 2>/dev/null)

    if [[ $screen =~ $BUSY_RE ]]; then
      state=busy
    elif [[ $screen =~ $BLOCKED_RE ]]; then
      state=blocked
    elif [[ ${prev[$pane]-} == busy ]]; then
      state=done
    else
      state=${prev[$pane]-idle}
    fi
    [[ $onscreen == 1 && $seen_ok == 1 && $state != busy ]] && state=idle

    was=${prev[$pane]-idle}
    if [[ $state != "$was" ]]; then
      case $state in
        blocked|done) notify "$pane" "$label" "$state" ;;
        *) [[ $was == blocked || $was == done ]] && unnotify "$pane" ;;
      esac
    fi

    printf '%s %s\n' "$pane" "$state" >> "$tmp"
    printf '%s\t%s\t%s\n' "$pane" "$state" "$label"
  done < <(tmux list-panes -a -F \
    '#{pane_id}|#{pane_current_command}|#{window_name}|#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}')

  mv -f "$tmp" "$STATE"
}

# status → the status-right segment. Silent when nothing is running.
status() {
  local busy=0 out="" pane state label
  while IFS=$'\t' read -r pane state label; do
    case $state in
      busy) ((busy++)) ;;
      blocked) out+="#[fg=yellow]$ICON_BLOCKED $label " ;;
      done) out+="#[fg=green]$ICON_DONE $label " ;;
    esac
  done < <(scan)
  ((busy > 0)) && out="#[fg=blue]$ICON_BUSY $busy $out"
  [[ -n $out ]] && printf '%s#[default]' "$out"
}

# preview <pane> — a live view of the pane, redrawn every second.
# fzf has no preview timer, so the loop lives here. \033[2J clears fzf's
# preview buffer, so each cycle replaces the last rather than appending; the
# scrollback comes along, which is what ctrl-f lets you scroll back into.
preview() {
  local pane=$1
  while :; do
    printf '\033[2J\033[H'
    tmux capture-pane -pe -S -400 -t "$pane" 2>/dev/null |
      awk 'NF { last = NR } { a[NR] = $0 } END { for (i = 1; i <= last; i++) print a[i] }'
    sleep 1
  done
}

# focus <pane> — used by the picker and by a clicked notification.
focus() {
  local pane=$1
  tmux switch-client -t "$(tmux display -pt "$pane" '#{session_name}')" 2>/dev/null
  tmux select-window -t "$pane" 2>/dev/null
  tmux select-pane -t "$pane" 2>/dev/null
  open -a Ghostty 2>/dev/null
}

# pick → fzf popup over every agent pane, attention first, Enter jumps to it.
pick() {
  local list pane state label
  list=$(mktemp) || return 1
  trap 'rm -f "$list"' EXIT

  while IFS=$'\t' read -r pane state label; do
    case $state in
      blocked) printf '0\t%s\t\033[33m%s\033[0m  %-26s\033[33mwaiting on you\033[0m\n' "$pane" "$ICON_BLOCKED" "$label" ;;
      done)    printf '1\t%s\t\033[32m%s\033[0m  %-26s\033[32mfinished\033[0m\n'       "$pane" "$ICON_DONE"    "$label" ;;
      busy)    printf '2\t%s\t\033[34m%s\033[0m  %-26s\033[90mworking…\033[0m\n'       "$pane" "$ICON_BUSY"    "$label" ;;
      *)       printf '3\t%s\t\033[90m%s\033[0m  %-26s\033[90midle\033[0m\n'           "$pane" "$ICON_IDLE"    "$label" ;;
    esac
  done < <(scan) | sort > "$list"

  if [[ ! -s $list ]]; then
    printf '\n  %s  no agent panes\n' "$ICON_IDLE"
    read -rsn1 -t 2
    return 0
  fi

  local sel
  sel=$(FZF_DEFAULT_OPTS= fzf \
    --ansi --no-sort --cycle --highlight-line \
    --border=none --margin=0 --padding=0 --info=inline-right \
    --prompt='❯ ' --pointer='▌' \
    --header='enter  jump    ctrl-f  freeze scroll    esc  cancel' --header-first \
    --color='fg:-1,bg:-1,gutter:-1,fg+:green:bold,bg+:-1,hl:green,hl+:green:bold,pointer:green,prompt:green,info:8,header:8,border:8' \
    --delimiter=$'\t' --with-nth=3 --nth=3 \
    --bind 'tab:down,btab:up' \
    --preview "$SCRIPT --preview {2}" \
    --preview-window 'right:62%:follow:noinfo:border-left' \
    --bind 'ctrl-f:change-preview-window(right:62%:noinfo:border-left|right:62%:follow:noinfo:border-left)' \
    < "$list") || return 0
  [[ -z $sel ]] && return 0

  focus "$(cut -f2 <<<"$sel")"
}

case "${1:-}" in
  --pick)    pick ;;
  --list)    scan ;;
  --preview) shift; preview "${1:-}" ;;
  --focus)   shift; focus "${1:-}" ;;
  *) status ;;
esac
