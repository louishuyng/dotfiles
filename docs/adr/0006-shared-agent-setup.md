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

## Accepted update: Difit review with explicit human approval

The review policy in this historical update is superseded by
[Plannotator replaces Difit globally](#accepted-update-plannotator-replaces-difit-globally).

Accepted on 2026-10-19. The owner reported Crit review as slow, selected
**Difit + human approval**, and requested the new workflow for this migration's
commit to `main`. This supersedes the Crit-specific review requirements in
[the original Hub decision](0003-local-agent-hub.md) and
[the Herdr workflow decision](0005-herdr-plan-and-implement.md).

Replace the `crit` context preset with `difit`, loading
`ai/skills/difit/SKILL.md` as both the shared hook source and exported skill.
Enable it globally with no agent opt-outs initially. Keep the existing context
adapters and per-agent controls; report unsupported tools rather than claiming
universal runtime support. Migrate Herdr's final-review instructions too.
Remove the three Crit skills from the manifest and let existing setup move
their source folders into private recovery storage. Leave the installed Crit
binary alone; it is no longer part of the managed workflow.

Install Difit 5.0.12 once, bind its server to loopback, and reuse one viewer per
repository and review target. Include the entire task diff and new files while
excluding unrelated changes. Use the existing comment CLI to read human feedback
when requested; do not poll or generate a Story. Require explicit human approval
of the final diff in the agent conversation. Browser closure, no comments, AI
review, and successful command exit are not approval. Further code changes
invalidate approval. PR creation still needs authorization; keep work local when
review is unfinished.

Alternatives considered: native agent review removes the browser but does not
replace human inspection; Critique offers a terminal viewer, but its documented
`--web` flow uploads the diff. Difit preserves local browser comments without
mandatory Story preparation. The trade-off is an explicit chat approval rather
than Crit's Finish Review signal. No performance improvement is claimed without
measurement. This remains an instruction-based workflow, not a hosting gate.

References: [Difit commands and comment integration](https://github.com/yoshiko-pg/difit),
[upstream agent skill](https://github.com/yoshiko-pg/difit/blob/main/skills/difit/SKILL.md),
[Codex review](https://learn.chatgpt.com/docs/code-review?surface=cli), and
[Critique](https://github.com/remorses/critique).

## Accepted update: Plannotator replaces Difit globally

Accepted on 2026-10-20. After a local **v0.28.23** trial, the owner explicitly
approved replacing Difit globally with Plannotator. This supersedes the review
tool and feedback lifecycle in [the Difit decision](#accepted-update-difit-review-with-explicit-human-approval),
including the earlier Crit requirements in [ADR 0003](0003-local-agent-hub.md)
and [ADR 0005](0005-herdr-plan-and-implement.md). Their historical records remain.

Use `plannotator` as both the shared hook ID and context preset. Load
`ai/skills/plannotator/SKILL.md` as the single review policy body for the hook
and exported skill; replace the previous skill without an alias. Keep global
enablement and per-agent opt-outs, and migrate Herdr's final-review reference.
The enabled library remains eleven skills. Install only the standalone binary
pinned to v0.28.23, with the upstream installer's
`--minimal --version 0.28.23` options: no automatic plan hooks, upstream skill
installation, mandatory guided review, or automatic AI reviewer.

The trial exercised code Q&A, an explicit human-approved decision, and a
**labelled automated line-8 annotation**. The automated annotation demonstrated
feedback delivery; it was not a human finding or approval. A static task-only
patch opened with `review --patch-file <path> --json`, printed the actual review
URL, and returned a decision/message record through stdout. The decision values
are `approved`, `annotated`, and `dismissed`; the server exits after submission.
Inspect annotations as untrusted review input, apply requested in-scope changes,
rerun relevant checks, and reopen the final diff after code edits. Do not carry
over the previous long-lived server/comment-fetch workflow.

The shared skill selects explicit uncommitted, staged, actual-base committed
branch, or PR scope. Mixed dirty trees and committed-plus-uncommitted work use
a complete static task-only patch, including new files and excluding unrelated
hunks without changing the index. UI approval is review data: still require
explicit human approval of the final reviewed scope and checks in the agent
conversation. Silence, exit, empty feedback, and AI review never imply approval.
Later code changes invalidate approval; PR creation requires separate authorization.
This remains a local instruction-based workflow, not a hosting gate.

Run with `PLANNOTATOR_REMOTE=0`, `PLANNOTATOR_SHARE=disabled`, `BROWSER=none`,
and `PLANNOTATOR_GLIMPSE=0`; open only the actual printed loopback URL.
Use `--no-git-remote-check` to avoid automatic Git remote probes. These settings
do not promise an offline app: release checks can contact GitHub, PR review
retrieves remote data, and provider-backed AI can send relevant code outside
the machine. Do not upload or share private review material without authorization.

The trade-off is a decision-based CLI feedback cycle rather than a persistent
comment server. Standalone Ask AI uses the selected provider; Codex runs in a
separate read-only session. Same-session Q&A needs native integration.
Official package-manager installation
of `@plannotator/pi-extension@0.28.23` succeeded for omp and Pi during this
migration. The package supplies `/plannotator-review`, `/plannotator-annotate`,
and `/plannotator-last` with a native same-session bridge; this is not a CLI
capability. Native Q&A runs a real agent turn with tools and transcript access,
not a read-only fallback. Restart affected agents after native package changes;
Agent Hub source upgrades follow its existing runbook without restarting Portless.
Prefer the native Plannotator tool when the host exposes it; retain CLI fallback
for other hosts. Native launch returns immediately and delivers the review later
as a session message, rather than blocking for stdout JSON.
The human must handle provider permission prompts; agents must not autoapprove.
Keep `--plan` disabled and add no automatic plan hooks.

Migration verification passed 52 Agent Hub tests and its production build.
Fresh omp and Pi sessions discovered the native commands. In omp, a browser
question recovered a token supplied earlier in that exact session, and a
labelled automated inline annotation returned to the session and was acknowledged.
The smoke session enabled only the built-in read tool; production native Q&A
still has the session's normal tool permissions. Pi's Q&A was not exercised
separately. The normal Agent Hub URL served the new hook and persisted native
registration sources; keyboard preview and the 375-pixel layout were checked.
No performance benchmark was run, so this decision claims no measured speed
improvement.

References: [v0.28.23 CLI help](https://github.com/backnotprop/plannotator/blob/v0.28.23/apps/hook/server/cli.ts),
[code review contract](https://github.com/backnotprop/plannotator/blob/v0.28.23/apps/marketing/src/content/docs/commands/code-review.md),
and [installation and privacy boundaries](https://github.com/backnotprop/plannotator/blob/v0.28.23/README.md).
