#!/bin/bash
# Listening (LISTEN) ports on this Mac: servers started from the work folder (~/workspace) + OrbStack (docker) · ollama.
# Each row is "name · detail": docker = container name, java = gradle daemon / app main class, node etc. = executable, ollama = loaded models
# The popup shows up to 12 rows; overflow becomes '+N more · show all' — click for the full list in a terminal. Every 15 s
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
WORK="${WORK_DIR:-$HOME/workspace}"; ALL="$HOME/.cache/sketchybar/ports.all"

RAW=$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {n=split($9,a,":"); print $2 "\t" $1 "\t" a[n]}' | sort -u)
PIDS=$(cut -f1 <<<"$RAW" | sort -u | paste -sd, -)
CWDS=$(lsof -a -d cwd -p "$PIDS" -Fpn 2>/dev/null | awk '/^p/{p=substr($0,2)} /^n/{print p "\t" substr($0,2)}')
# Docker port → container name (the 3110 in "127.0.0.1:3110->3000/tcp"), ollama loaded models — heavy, so only once a minute (cached otherwise)
DC="$HOME/.cache/sketchybar/ports.docker"; OC="$HOME/.cache/sketchybar/ports.ollama"
if [ -z "$(find "$DC" -mmin -1 2>/dev/null)" ]; then
  DK=$(command -v docker || echo "$HOME/.orbstack/bin/docker")   # SketchyBar's PATH has no OrbStack docker
  "$DK" ps --format '{{.Names}}\t{{.Ports}}' 2>/dev/null | while IFS=$'\t' read -r nm ps; do
    tr ',' '\n' <<<"$ps" | sed -n 's/.*:\([0-9]*\)->.*/\1/p' | sort -u | while read -r hp; do echo -e "$hp\t$nm"; done; done > "$DC"
  "$(command -v ollama || echo /opt/homebrew/bin/ollama)" ps 2>/dev/null | awk 'NR>1{print $1}' | paste -sd, - > "$OC"
fi
DOCK=$(cat "$DC"); OLL=$(cat "$OC" 2>/dev/null)

LIST=$(while IFS=$'\t' read -r pid proc port; do
  case "$proc" in
    (OrbStack*) c=$(awk -F'\t' -v p="$port" '$1==p{print $2; exit}' <<<"$DOCK")
      if [ -n "$c" ]; then echo -e "$port\t$c · docker"; else echo -e "$port\tOrbStack internal · ssh·api"; fi; continue ;;
    (ollama) echo -e "$port\tollama · ${OLL:-no model}"; continue ;;
  esac
  cwd=$(awk -F'\t' -v p="$pid" '$1==p{print $2}' <<<"$CWDS")
  case "$cwd" in ("$WORK"/*) ;; (*) continue ;; esac
  top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$cwd")
  cmd=$(ps -o command= -p "$pid" 2>/dev/null)
  case "$proc" in
    (java) case "$cmd" in (*GradleDaemon*) d="gradle daemon" ;; (*) d=$(awk '{print $NF}' <<<"$cmd"); d="java ${d##*.}" ;; esac ;;
    (node) set -- $cmd; b=${1##*/}; [ "$b" = node ] && d="node ${2##*/}" || d="node $b" ;;   # a process that renamed itself (like next-server) keeps that name
    (*) d="$proc" ;;
  esac
  echo -e "$port\t${top##*/} · $d"
done <<<"$RAW" | sort -t$'\t' -k1,1n -u)
N=$(grep -c . <<<"$LIST")
printf '%s\n' "$LIST" > "$ALL"

MAX=30   # max rows shown in the popup. Beyond that the last row is '+N more · show all'
SHOW="$CONFIG_DIR/plugins/show_list.sh ports"
{
  head -n $MAX <<<"$LIST" | while IFS=$'\t' read -r port what; do
    [ -n "$port" ] && printf ':%s\t%s  ↗\t%s\topen http://localhost:%s\n' "$port" "$what" "$TEXT" "$port"
  done
  [ "$N" -gt $MAX ] && printf '…\t+%s more · show all ↗\t%s\t%s\n' $((N - MAX)) "$TEXT2" "$SHOW"
} | perl "$CONFIG_DIR/plugins/fit.pl" 260 | popup_rows ports PORTS

# The cell is a pixel icon only (rev 7) — the port count shows only in the popup
