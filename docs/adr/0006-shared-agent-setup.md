# Shared agent setup uses repository-owned sources

Status: accepted on 2026-10-16.

## Decision

Agent Hub's owner needs one place to add MCP servers, skills, and command hooks
and distribute changes to available agents, including Cursor. All managed source
configuration lives under `.dotfiles/ai`. The owner approved the shared setup
page and native adapters, then explicitly required this repository source of truth.

Use [`ai/config/shared-setup.json`](../../ai/config/shared-setup.json) for shared
MCP definitions and command hooks. Keep the existing
[`ai/skills/manifest.json`](../../ai/skills/manifest.json) and skill folders as the
skill authority. Existing native hook sources remain in `ai/hooks`; the shared
hook adapter merges its registrations into those files and their native exports.

The Shared setup page supports adding, editing, enabling, disabling, and removing
servers and hooks. Changes have a diff preview and an optimistic source revision.
Importing a native server requires an explicit action and rejects fields that
cannot be translated without loss. Initial shared configuration includes the
existing Linear HTTP endpoint. It contains no credentials.

## Export and reconciliation

Export MCP definitions to Codex TOML, Claude Code's user MCP section, OpenCode
v2's `mcp.servers`, Gemini's `mcpServers`, Cursor's `mcpServers`, Copilot CLI's `mcpServers`, and Pi's `~/.pi/agent/mcp.json`.  A command or existing configuration directory activates an adapter;
Cursor does not require its CLI. Save operations reconcile immediately. Startup
and the existing 60-second maintenance loop reconcile repository edits and newly
detected targets. Skill additions and enablement changes activate sharing when
needed, and maintenance includes newly detected skill targets even when the
library fingerprint has not changed.

Support stdio commands and Streamable HTTP endpoints. Preserve unrelated native
fields, comments, and unowned servers. A conflicting unowned name blocks that
target instead of overwriting its settings. Show extra native servers and
unsupported options as incomplete parity. Disabling or deleting a shared server
removes only previously managed exports; refuse removal if that export changed
outside Agent Hub. Project overrides, vendor connectors, connection health, and
OAuth sessions require native verification.

Shared command events map to Codex/Claude `PreToolUse`, `PostToolUse`, and `Stop`;
Cursor `preToolUse`, `postToolUse`, and `stop`; and Gemini `BeforeTool` and
`AfterTool`. Gemini has no mapped response-completion event. Other agents retain
their native hook systems and show unsupported shared hooks. Commands receive
native input and must handle runtime-specific payloads, tool names, output
contracts, and working directories. Sharing a command does not normalize these
contracts or replace a security boundary.

## Recovery and privacy

Keep private export receipts, transaction journals, and backups in
`~/.local/share/agent-hub`. These are operational state, not configuration
authority. Before replacing native files, preserve their original contents in
`shared-backups`. Journal each transaction and roll back failed or interrupted
writes. Refuse recovery if an affected file contains an unexpected external
change. Native settings outside the MCP/hook sections never enter the API.

The repository source is inspectable and may be committed. Do not put credentials
in shared server definitions or hook commands. This version rejects native
environment interpolation rather than copying incompatible syntax. Servers that
need such settings remain native and appear as incomplete parity. OAuth tokens
remain owned by each agent. Private backups can contain original credentials.

## Alternatives and trade-off

Independent native settings leave additions out of sync; copying identical files
breaks incompatible formats. A private central source would protect inline
credentials but violate the owner's explicit repository-authority requirement.
Repository-owned definitions and small native adapters satisfy that requirement
while exposing unsupported settings. If portable environment references become
necessary, add explicit reference fields and translate them per runtime rather
than copying one agent's interpolation syntax.

## Adapter references

- [Codex MCP configuration](https://learn.chatgpt.com/docs/config-file/config-reference)
  and [command hooks](https://learn.chatgpt.com/docs/hooks).
- [Claude Code MCP scopes](https://code.claude.com/docs/en/mcp).
- [OpenCode v2 MCP configuration](https://dev.opencode.ai/v2/docs/mcp-servers/).
- [Gemini MCP configuration](https://geminicli.com/docs/tools/mcp-server/) and
  [hook events](https://geminicli.com/docs/hooks/reference/).
- [Cursor MCP locations](https://cursor.com/docs/mcp),
  [Cursor hook events](https://cursor.com/docs/hooks), and
  [Copilot CLI MCP configuration](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers).

## Accepted update: shared policies with agent opt-outs

The owner requested three shared context hooks: ADHD, Ponytail, and Crit. Each
hook has one repository body, an enabled default, and a `disabledAgents` list.
Both Shared setup and the Hooks workspace edit those same values. Opting one
agent out removes only that registration; it does not change the shared body or
other agents. Starting a new session clears previously injected instructions.

Move the Crit review policy to `ai/hooks/crit.md` and remove it from AGENTS.md.
Move the ADHD output rules out of AGENTS.md as well, so disabling ADHD has a real
effect. Ponytail and ADHD load their existing skill bodies. Native startup hooks
receive the correct context output schema. OpenCode's context plugin and Pi's
before-agent extension load the same source and preferences each turn.

Remove legacy native Superset, Herdr, RTK, Caveman, and duplicate Crit hook
registrations, preserving recovery copies. Disable duplicate mode plugin
providers and exclude Pi's Herdr/notification extensions without deleting their
files. Keep unrelated native plugin functionality. Crit remains an instruction
injected by an optional hook; it cannot intercept every PR creation route.

This replaces the always-on policy recorded in the previous Agent Hub decision.
The trade-off is deliberate: an opted-out agent no longer receives the Crit
review requirement from Agent Hub. A mandatory review gate would need repository
hosting enforcement instead of a user-controlled local hook.

## Accepted update: author text, skill, and command hooks

The owner approved three explicit choices in Add hook: context text, a shared
skill reference, and a native command. Store exactly one source per hook:
`text`, `skill`, or `command`. Preserve existing `context` presets for the three
default hooks. Text and skill hooks use `sessionStart`; command hooks select a
supported native event. All retain shared enablement and per-agent opt-outs.

Skill references identify library names, not arbitrary paths. Validate source
existence and reject symlinks outside `ai/skills` before saving. Load the current
skill body when the hook runs; do not copy it into configuration or execute its
scripts. The workspace and native runners use the same context reader so the
visible preview matches the injected text.
