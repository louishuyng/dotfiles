# 0005: plan in Codex before Herdr implementation on macOS

Accepted on 2026-10-16. The owner chose the `herdr-plan` → `herdr-implement`
workflow over investigating a new native macOS sandbox.

The Crit-specific review steps below are superseded by
[Plannotator replaces Difit globally](0006-shared-agent-setup.md#accepted-update-plannotator-replaces-difit-globally).

## Context

Herdr Projects 1.0.1 requires bubblewrap for native planning in repo worktrees.
Bubblewrap uses Linux namespaces and cannot supply this boundary on this Mac.
The owner's workflow also requires human Crit approval before any PR, while
Projects normally creates a draft PR before its AI review.

## Decision

`herdr-plan` opens the board and plans in the current Codex chat. It changes no
product code and hands off only a human-approved plan. `herdr-implement` puts
that plan into a new implementation task, uses Codex for work and AI review,
and requires interactive Crit approval of the final diff before authorized
manual PR creation.

Set the personal defaults to `plan.approve none`, `merge.pr false`, and
`merge.by you`. The implementation skill verifies these values for each task
because repo and task overrides take precedence. Keep the skills in the shared
`ai/skills` library and enable them through its manifest.

## Trade-off

Planning is constrained by human approval and agent instructions, not Projects'
kernel-enforced read-only mount. This preserves the upstream sandbox behavior
and avoids maintaining a platform-specific plugin fork. Crit's gate is likewise
a workflow rule, not a server-enforced approval mechanism. If enforced planning
becomes required, use a supported Linux host with bubblewrap or adopt a verified
upstream macOS sandbox. Never spoof `bwrap` or bypass its readiness check.

## References

- [Projects planning](https://github.com/eliasstravik/herdr-projects/blob/v1.0.1/docs/plan.md)
- [Projects finish sequence](https://github.com/eliasstravik/herdr-projects/blob/v1.0.1/docs/how-work-gets-done.md)
- [Bubblewrap](https://github.com/containers/bubblewrap)
- [Shared skill authority](0003-local-agent-hub.md)
