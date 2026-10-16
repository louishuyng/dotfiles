---
name: herdr-plan
description: Plan work with the human in Codex, open the Herdr Projects board, and prepare an approved plan for herdr-implement. Use when the user invokes herdr-plan or asks to plan a Herdr task before implementation. Do not implement or delegate from this skill.
---

# Plan before Herdr implementation

Open the Projects board, plan in the current chat, and wait for the human's
approval. Use the installed `herdr-projects` skill for board operations and
`tech-doc-writer` for the plan. Keep the source checkout unchanged while planning.

## Workflow

1. **Open the board by default.** Check `herdr status server` and run
   `herdr plugin action invoke open --plugin herdr-projects`. This opens or
   returns to the existing board. If Herdr is unavailable, report why and
   continue planning in the current chat; do not launch a nested multiplexer.
2. **Understand the task.** Read repository instructions, trace the affected
   code and callers, and identify the checks and working-tree changes that
   must be preserved. Ask about materially different interpretations.
3. **Write the plan.** Include the problem and acceptance criteria, the
   recommended approach and trade-off, ordered implementation steps, relevant
   checks, and unresolved decisions. Name affected paths. Use an existing plan
   location if the user supplies one; otherwise save outside the checkout in
   the system temporary directory and give its absolute path.
4. **Discuss and revise.** Wait for explicit approval of the plan. Do not treat
   silence, opening the board, or an AI review as approval. Do not delegate,
   edit product code, commit, push, or create a PR.
5. **Hand off the approved version.** Supply the repo's absolute path, plan text
   and path, acceptance criteria, checks, and the human's approval. Explain that
   invoking `herdr-implement` starts implementation; approving a plan alone
   does not authorize starting it.

## macOS and native plan mode

Projects 1.0.1's native `plan.approve` mode requires Linux bubblewrap (`bwrap`)
for repo tasks. This workflow plans in the current chat instead. The subsequent
implementation task must use `plan.approve none` and include the approved plan
in its description. Do not use `HERDR_PROJECTS_SANDBOX` overrides, fake a
`bwrap` executable, or patch away the sandbox check.

This is a human approval workflow, not an enforced read-only planning sandbox.
If kernel-enforced planning is required, stop and use a supported Linux host
with working bubblewrap or a verified upstream macOS implementation.

## Invocation

```text
Use herdr-plan to plan a fix for the Fish startup delay. Open the board,
inspect the startup flow, and propose the smallest change. Do not implement.
```
