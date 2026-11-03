# SketchyBar Island with AeroSpace

This is an adaptation of [garamnohhh/sketchybar-island](https://github.com/garamnohhh/sketchybar-island/tree/26b80f66fb7ac1cfc940cc7eebc8e41c06c3797b), used under its [MIT license](LICENSE). It replaces the active Lua bar with notch-aligned islands, media controls, agent usage, a CPU cat, and popups. The upstream documentation is in [README.upstream.md](README.upstream.md).

## Setup

Keep `~/.config/sketchybar` symlinked to this directory. Install the dependencies and build the helpers from this directory:

```sh
brew install media-control coreutils
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
bash helper/build.sh
sketchybar --reload
```

SketchyBar, AeroSpace, Python 3, and Xcode Command Line Tools must already be installed. Compiled helpers are ignored by Git and must be rebuilt on a new Mac. Do not run the upstream installer: it replaces the dotfiles symlink.

Edit [config.sh](config.sh) for appearance and personal settings. The theme follows macOS appearance; Rectangle auto-maximize is disabled because AeroSpace manages windows. The ports popup searches processes under the home directory.

The leftmost title shows the focused AeroSpace workspace, followed by the green cursor. The existing `aerospace_workspace_change` hook updates it immediately, with a five-second polling fallback. Failed or stalled AeroSpace calls leave the last good display intact. Workspace and front-app names share a layout lock; each title resize, media resize, and progress-fill adjustment is sent in one animation. macOS Reduce Motion disables that animation.

Apple Music is shown by its friendly name even when Spotlight cannot resolve the app's bundle identifier.

## Agent circle and Claude usage

The face circle shows live coding agents running in Herdr (Claude Code, Codex, Pi, Grok Build, and any other agent herdr-core recognizes). [`plugins/agent_watch.sh`](plugins/agent_watch.sh) follows `hc events` and fires `agent_status_change` when a terminal starts, ends, or changes status; [`plugins/pilo.sh`](plugins/pilo.sh) then reads `hc ls` and `hc get`. A working agent shows as running, an approval prompt as waiting (red), and an ended turn as idle; an agent still working with no status change for 10 minutes shows as stalled (yellow). A 30-second poll is the backstop. Agents outside Herdr, such as one in plain tmux, do not appear. Clicking a session row raises Herdr and focuses that agent's terminal. Set `PILO_ISLAND=0` in `config.sh` to hide the circle.

The agent cell shows Claude and Codex 5-hour usage, plus the Grok weekly pool from the newest Grok Bot local reading (`percentUsed` / `nextResetMs`). A missing or past-reset reading shows —; the bar does not call xAI. The Claude usage cell reads the newest available local source: Claude Code's `/usage` cache, Claude desktop history, or reports written by Pilo's bundled `pilo-usage` plugin. The Fish configuration enables the plugin for new Claude sessions after Pilo has started. Restart Claude from a new Fish shell to load it; the first measurement writes a report after a turn. Alternatively, run `/usage` in Claude Code to populate its cache. While no source exists, the popup says `claude · run /usage`; a missing reading is not a measurement of zero usage. No account credentials are read by the bar.

The front-app menu requires Accessibility permission for SketchyBar. Nearby Wi-Fi scanning requires Location permission for SketchyBar Wi-Fi Scan; calendar events require Calendar access. Grant these in macOS when prompted if you want those features. The calendar grid works without calendar-event access.

## Restore the Lua bar

The original Lua modules and assets remain in this directory. Restore the saved entry point, then reload:

```sh
cp sketchybarrc.lua-backup sketchybarrc
sketchybar --reload
```

The island startup stops its previous media/audio watchers when reloaded. After switching back to Lua, restart SketchyBar to clear the island's background helpers as well. 
