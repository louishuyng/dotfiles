# Edit OpenCode configuration in dotfiles

For the dotfiles owner: edit this directory to update the active OpenCode v2
configuration. OpenCode reads `~/.config/opencode/opencode.jsonc`, which links to
this directory's `opencode.jsonc`. Runtime data, credentials, vendor checkouts,
and backups stay outside this repository.

## Files

| Path | Purpose |
| --- | --- |
| `opencode.jsonc` | MCP servers, command templates, plugin options, and default agent |
| `agents/` | Review and Research profiles; Build and Plan are built in |
| `skills` | Link to the current shared skills in `../ai/skills` |
| `AGENTS.md` | Link to shared engineering and output rules in `../ai/AGENTS.md` |
| `plugins/` | Local v2 hooks for Ponytail/ADHD and RTK |

The ADHD default is enabled by `.i-have-adhd-always`, linked into OpenCode's
config directory. Per-session mode commands can change this default for that
session. Shared `AGENTS.md` output rules still apply independently of the mode.

## Agent menu

| Agent | Use it for |
| --- | --- |
| Build | Implement and fix code using relevant shared skills |
| Plan | Explore code and propose implementation steps |
| Review | Inspect supplied changes for bugs, regressions, and unnecessary complexity |
| Research | Investigate code and compare technical options using primary sources |

Review and Research allow reading, searching, web research, skill loading, and
questions. They deny edits, shell commands, child agents, and MCP actions. Supply
a diff to Review when file context alone does not identify the changes. These
profiles do not pin a model; selecting a primary agent preserves the session's
selected model. Existing chats retain their saved agent selection until changed.

## What `codex-modes` does

`plugins/codex-modes` is a local OpenCode v2 plugin. It is not a Codex app plugin.
It registers `/ponytail` and `/i-have-adhd`, stores mode choices per session, and
adds the upstream Ponytail and ADHD rules to each model request's context.
Ponytail defaults to `full`; ADHD defaults to enabled for new sessions.

Keep this plugin for automatic hooks. Native skills alone provide on-demand
instructions. The internal ID stays `codex-modes` to preserve plugin storage.
The separate `rtk` plugin calls `rtk rewrite` before shell execution and adds
RTK instructions to context. Unsupported commands retain their original form.

Caveman is a shared skill, invoked through `/caveman`, `/caveman lite`, or
`/caveman ultra`. Use `/caveman off` to resume normal prose. It is not an
always-on context hook.

## Apply an edit

1. Edit `opencode.jsonc`, a file in `agents/`, or a shared skill in `../ai/skills`.
2. Reload with the desktop v2 CLI:

   ```sh
   rtk proxy "$HOME/Library/Application Support/ai.opencode.desktop/cli/2.0.21/opencode-cli" reload
   ```

3. Open the agent menu to verify the roles. Check server connections when changing MCP configuration:

   ```sh
   rtk proxy "$HOME/Library/Application Support/ai.opencode.desktop/cli/2.0.21/opencode-cli" mcp list
   ```

This machine currently uses desktop CLI 2.0.21. Use its replacement path after a
desktop update. The Homebrew `opencode` executable is still v1 and is not the
runtime used by this setup.

## Dependencies and rollback

The configured MCP servers are computer-use, Linear, and Whiteboard. Computer-use
and Whiteboard currently reference locally installed Codex assets. Moving the
configuration into dotfiles does not install those assets on a new machine.

The hook plugins also require RTK at `/opt/homebrew/bin/rtk` and the upstream
Ponytail and ADHD checkouts under `~/.config/opencode/vendor/`. Update those
checkouts with `rtk git -C <checkout> pull --ff-only`, review compatibility, then
reload. Existing command templates may need refreshing after an upstream update.
The `ai` task in `bootstrap/mac.sh`, `bootstrap/arch.sh`, or `bootstrap/debian.sh`
links configuration, agents, skills, shared rules, and the ADHD
flag; it does not install these dependencies.

The migration backup is
`~/.config/opencode/backups/before-dotfiles-link-20261001-164059/`. It contains the
previous configuration, legacy agent profiles, old OpenCode skills, and original
links. Restore its `opencode.jsonc` as a regular global config file and restore
`old-opencode-agents` plus the original agent link to recover the previous menu.
Restore `old-opencode-skills` and repoint the skills link to recover those skills.
Reload and verify the configuration after rollback.

References: [OpenCode agents](https://opencode.ai/v2/docs/agents),
[skills](https://opencode.ai/v2/docs/skills),
[configuration](https://opencode.ai/v2/docs/config), and
[the hook decision](../docs/adr/0001-opencode-native-skills.md).
