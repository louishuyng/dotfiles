#!/bin/bash
set -e

npm install --global --prefix "$HOME/.local" @garamnohhh/pilo@0.3.4
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/.pilo/logs"
python3 - <<'PY'
from pathlib import Path
import plistlib

home = Path.home()
job = {
    'Label': 'dev.garamnoh.pilo',
    'ProgramArguments': ['/bin/bash', str(home / '.dotfiles/terminals/pilo/service.sh')],
    'RunAtLoad': True,
    'KeepAlive': True,
    'ThrottleInterval': 30,
    'ProcessType': 'Background',
    'StandardOutPath': str(home / '.pilo/logs/service.log'),
    'StandardErrorPath': str(home / '.pilo/logs/service.err.log'),
}
with (home / 'Library/LaunchAgents/dev.garamnoh.pilo.plist').open('wb') as file:
    plistlib.dump(job, file)
PY
launchctl bootout "gui/$(id -u)/dev.garamnoh.pilo" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/dev.garamnoh.pilo.plist"
