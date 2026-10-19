# 0003: use LX14-AI-Skills as the local Agent Hub authority

Accepted on 2026-10-13. The owner approved building Agent Hub and subsequently chose the repository library, **LX14-AI-Skills**, as the shared source. This decision replaces the earlier proposal to export Codex's discovered catalogue.

The Crit-specific review policy and skill set below are superseded by
[Difit review with explicit human approval](0006-shared-agent-setup.md#accepted-update-difit-review-with-explicit-human-approval).

This proposal is for the dotfiles owner. It defines the first complete version of
a web application for managing Codex Desktop, Claude Code, and OpenCode on this Mac.
It records the stack, shared-skill behavior, dashboard, and login service for future maintenance and recovery. Here, “Claude” means the installed Claude Code tool.

## Recommendation

Build `ai/agent-hub/` with React, TypeScript, Vite, Tailwind CSS, shadcn/ui, Lucide
icons, and Recharts. A Node 24 service serves the compiled UI and a local API.
Use Node's filesystem, HTTP, test, and SQLite facilities instead of adding a
backend framework or database service. Keep agent configuration in its existing
files; store only rebuildable usage summaries and file offsets in a private local
SQLite cache outside Git.

The UI has five destinations: Dashboard, Skills, Plugins, Hooks, and Instructions.
Use a restrained developer-console design with light/dark themes, a sidebar,
searchable tables, readable charts, and an editor with a diff before applying changes.
The `ui-ux-pro-max` skill guides interface review. Prefer system sans/monospace fonts to external
font requests. Keyboard access, visible focus, reduced motion, contrast, and
responsive layouts are acceptance requirements.

## Original setup and change boundary

Before Agent Hub, `~/.agents/skills`, `~/.claude/skills`, and `~/.config/opencode/skills` pointed to `ai/skills/`. Codex's global instructions point to `ai/AGENTS.md`; Claude's point to `ai/CLAUDE.md`. OpenCode also had explicit vendor skill roots and two local v2 plugins. Preserve instruction sources and hook behavior unless the owner accepts coupled plugin suppression. Back up and clear OpenCode's explicit vendor roots when enabling shared discovery, because those roots can take precedence. Preserve the vendor folders themselves.

The change reaches the new application and tests, `bootstrap/setup.sh`'s AI setup,
the login-service installer, shared skill links, and agent-specific configuration
adapters. Runtime caches, backups, and logs remain outside the repository. Do not
change unrelated editor, terminal, or window-manager work.

## Share LX14-AI-Skills from the repository

The catalogue includes 21 branded tools. Full configuration adapters cover Codex, Claude Code, and OpenCode; Gemini, Copilot, Cursor, Grok Build, and Pi have narrower file adapters. Other entries identify their native configuration handoff. SuperGrok is a web account, with no fabricated local skill or usage API. New native adapters require verified tool interfaces.

Use [`ai/skills`](../../ai/skills), named LX14-AI-Skills by its [`manifest.json`](../../ai/skills/manifest.json), as the authority. The manifest defines enabled names. The current set contains ten skills, including Crit's three skills and the repository copy of the Ponytail 5.1.0 base skill. Preserve licenses and supporting files. Setup moves inactive folders out of the active tree into a private timestamped recovery directory under `~/.local/share/agent-hub/disabled-skills/`.

Generate managed links for Codex's `~/.agents/skills`, Claude, OpenCode, and configured Pi, Gemini, Copilot, Cursor, or Grok Build to the same enabled source folders. Keep authoring in `ai/skills/`; Codex consumes this library rather than defining it. Preserve each complete folder so scripts and relative references resolve. Show missing, extra, unreadable, duplicate, and differently resolved entries, with reconciliation previews and backups. Refresh managed exports after library changes.

The repository gives consumers one reviewable source and enabled set. A Codex-derived catalogue would also export bundled/plugin skills and couple the library to installation state. Separate per-agent copies would let content diverge. The manifest avoids both problems, at the cost of maintaining selected copies and auditing native discovery separately. If per-agent skill sets become a requirement, revise this decision rather than adding silent exceptions.

Exact total parity requires a native discovery audit; matching exports alone is insufficient. Suppress competing global sources where supported. OpenCode's explicit vendor roots can take precedence over shared files, so back up and clear their configuration. Pi package registrations use `skills: []`; exclude old global skill roots while retaining extensions. Use supported Codex skill preferences for native discovery controls, without treating its catalogue as authority.

Claude plugin skills and hooks can share one enablement switch. Disabling a plugin to remove its skills can remove its hooks as well. Obtain owner agreement before that coupled change; setup records consent with `--strict-plugins`. Without consent, preserve those plugins and report incomplete parity. Unsupported or still-active native sources leave the target unverified; selected projects can introduce extra skills and need separate audits.

Sharing files does not provide a missing connector or lifecycle runtime. Keep plugins and hooks in native formats and show limitations explicitly. Native Codex plugins remain managed through supported app-server operations. Do not claim a verified total until exports and native discovery both pass.

## Manage native configuration

| Destination | First-version behavior |
| --- | --- |
| Skills | Search, inspect provenance and compatibility, create/edit custom skills, enable/disable, preview and repair shared links. |
| Plugins | Show installed/enabled state per tool; manage native enablement and local plugin registrations without flattening three different plugin systems. Use supported installation flows; show an explicit handoff when an operation is available only in the tool's own UI. |
| Hooks | Inspect and edit Codex/Claude hook configuration and OpenCode plugin registrations/source files. Preserve each runtime's hook format; do not translate lifecycle semantics automatically. |
| Instructions | Edit the active global AGENTS.md/CLAUDE.md sources and instructions for an explicitly selected project. Resolve symlinks and show which tools consume each file. |

Validate content before writing, reject stale edits, save atomically, and retain a
restorable backup. Keep file access restricted to known configuration roots and
explicitly selected projects. Bind the service to loopback and require same-origin
requests plus a session token for mutations. Do not expose credentials through
the API or execute arbitrary commands submitted by the browser.

## Dashboard: daily, weekly, and session context

Read existing history without installing telemetry hooks. Inspection confirmed
Codex JSONL usage/context records, Claude JSONL token usage, and OpenCode v2's
`session_v2`/`session_message` tables with token and cost fields. Read OpenCode's
database in read-only mode. Support the observed formats and report an unsupported
schema explicitly after a tool upgrade.

| Metric | Definition and limits |
| --- | --- |
| Activity | Sessions, turns, models, projects, and recorded tool calls/errors by tool; today, 7 days, 30 days, and selected date range. |
| Tokens | Input, output, cache read/write, and reasoning when recorded. Deduplicate streaming updates and use deltas for cumulative counters; never sum repeated session totals. |
| Context | Latest/peak recorded request context, context limit where recorded, and compaction count. Label request-token proxies; cumulative billed tokens are not context occupancy. |
| Cost | Recorded cost where available. Missing cost is “unavailable,” not zero. Subscription billing is not inferred from API token rates. |
| Health | Last source refresh, unreadable/malformed records, skill parity, plugin/hook state, and login-service status. Missing history is visible. |

Bucket dates in the machine's local timezone (currently Asia/Ho_Chi_Minh), with
Monday-based weeks. Include per-tool/model/project filters and a session table
for drill-down. Keep subagent usage identifiable and prevent parent/imported
session duplication. Index incrementally so opening the dashboard does not
reparse all histories. Process only metadata needed for metrics; do not persist
prompts, responses, or secrets in the dashboard cache.

## Run at login through Portless

Use the installed Node 24 and Portless executables.
Install two user LaunchAgents with `RunAtLoad` and restart-on-failure: one for a dedicated loopback HTTP proxy on port 1355, one for the compiled application through Portless under the name `agent-hub`. Use absolute executable paths and a controlled PATH. Isolate the proxy with `PORTLESS_STATE_DIR` so existing Portless apps are unaffected. This avoids administrator privileges and certificate changes. The resulting URL is `http://agent-hub.localhost:1355`.

The owner's 2026-10-13 request for `http://agent-hub.localhost` adds an explicit `service clean-url` migration. Use Portless's native macOS system startup service on port 80 with the same isolated state directory, retaining the user application LaunchAgent. Prefer the existing Portless installer over a second forwarding proxy or packet-filter rules. The trade-off is one administrator-authorized installation (and authorization for removal); the existing port-1355 setup remains available until migration runs. Refuse to replace another system Portless installation. Continue to use plain HTTP on loopback to avoid certificate changes.

The `agent_hub` bootstrap task runs dependency installation with `npm ci`, builds the UI, runs `node scripts/setup.mjs`, and installs the login services. Setup reads the repository manifest and reconciles the global enabled set before service installation. It does not derive authority from Codex's catalogue.

Verify both service layers now and inspect their persisted launchd configuration
for next-login behavior. Provide status, log, restart, and uninstall commands.
Show the actual URL in the UI. If trusted HTTPS becomes necessary, migrate this dedicated proxy to Portless's system service through a separate reviewed change.

## Alternatives and trade-off

A static dashboard cannot manage local files securely. A hosted site requires a
local bridge anyway. Electron adds packaging and another desktop runtime without
helping this browser-first request. The recommended local web application reuses
installed Node and Portless while adding a maintained UI stack.

The main trade-off is dependence on evolving native configuration/history
formats. Isolate each tool's reads and writes, keep backups, and show missing data.
If official stable usage/configuration APIs become available, replace the affected
adapter instead of extending file-format guesses. Native plugins and tool-bound
skills will continue to expose compatibility limits.

## Delivery and verification

1. Build the local service and read-only inventory.
2. Complete all five UI destinations and real daily/weekly usage aggregation.
3. Verify safe edits, backup/restore, parity reconciliation, and failure feedback
   against temporary configuration fixtures before changing the live setup.
4. Build and test the application; inspect desktop/mobile layouts, keyboard access,
   both themes, and reduced motion. Test token deduplication and timezone boundaries.
5. Install the login service, verify the real Portless URL and service restart,
   reconcile approved skill links, and document removal/rollback.

Completion means the UI uses real local data, configuration edits reach their
actual sources safely, shared skills have explicit parity status, and the
background service is installed and running. Claim exact total parity only after shared exports and native discovery both pass; selected projects need separate audits. A real logout/login test remains an
owner check unless the owner explicitly authorizes ending the current session.
Remote hosting, launching model conversations, and a replacement agent runtime
are outside this version.

## Implementation evidence

- [Repository manifest](../../ai/skills/manifest.json) and [shared configuration/sync](../../ai/agent-hub/server/config.mjs)
- [Native Codex operations](../../ai/agent-hub/server/codex.mjs)
- [Usage indexing](../../ai/agent-hub/server/usage.mjs)
- [Setup and pruning](../../ai/agent-hub/scripts/setup.mjs), [service installation/rollback](../../ai/agent-hub/scripts/service.mjs), and [bootstrap task](../../bootstrap/setup.sh)
- [Runbook and recovery commands](../../ai/agent-hub/README.md)

## Accepted update: repository-owned hooks and pre-PR review

On 2026-10-13 the owner requested global hook configuration and all UI-managed
global configuration under `ai/`, plus mandatory Crit review before PR creation.
Store managed hook/configuration sections in `ai/hooks` and `ai/config`, link
standalone files, and merge mixed native settings without copying credentials.
Keep one shared `ai/AGENTS.md`; retain compatibility links for existing agent
paths. Selected project instruction files remain project-owned.

Use a shared instruction for the PR review requirement: a command hook cannot
reliably intercept every native/API route to PR creation across all agent tools.
Require Crit approval of the final diff, select Crit Story at 10 changed files,
500 changed lines, or a cross-cutting architectural change, and invalidate the
approval after further code edits. A future hard gate belongs in repository
hosting checks with independently verifiable review evidence.
