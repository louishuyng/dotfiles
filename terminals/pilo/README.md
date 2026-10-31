# Pilo local service

[Pilo](https://github.com/garamnohhh/pilo) 0.3.4 runs at [localhost:48888](http://127.0.0.1:48888/welcome) as the `dev.garamnoh.pilo` macOS user service. It starts at login and restarts if its process exits. State stays under `~/.pilo`; the server listens on loopback.

## Install

With Node 24.22.1 or a compatible newer release managed by mise, run:

```sh
bash ~/.dotfiles/terminals/pilo/install.sh
pilo doctor
```

The installer puts the published npm package under `~/.local` and writes `~/Library/LaunchAgents/dev.garamnoh.pilo.plist`. Logs are in `~/.pilo/logs/service.log` and `service.err.log`.

## Connect a desk

Start Herdr and open a Claude Code or Codex session in one of its panes. Visit the [welcome page](http://127.0.0.1:48888/welcome) to select that session as the desk. Review the instruction-file changes shown by Pilo before registering project owners. No desk, project owners, tasks, or approval hooks are registered by this dotfiles installer.

SketchyBar shows the Pilo circle once the service responds. With no registered agents, its popup links to setup. After registration it shows the agents' actual states.

The bundled usage plugin is copied into `~/.pilo/mods/pilo-usage` when the server starts. [Fish configuration](../fish/conf.d/pilo.fish) adds that directory to the colon-separated `CLAUDE_CODE_PLUGIN_DIRS` without replacing other plugins. New Claude sessions write local usage reports after turns; SketchyBar and Pilo can read those reports. Existing Claude processes need to restart to load the plugin.

## Manage the service

```sh
# Restart the launchd-managed service.
launchctl kickstart -k "gui/$(id -u)/dev.garamnoh.pilo"

# Stop it, including automatic restarts, until the next login or bootstrap.
launchctl bootout "gui/$(id -u)/dev.garamnoh.pilo"
```

`pilo stop` alone is insufficient while launchd's KeepAlive policy is enabled. To disable login startup, boot out the job and move its plist out of `~/Library/LaunchAgents`. The database and history remain intact.
