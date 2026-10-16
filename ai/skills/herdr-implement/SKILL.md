---
name: herdr-implement
description: Implement a human-approved plan through Herdr Projects using Codex, run checks and AI review, then require interactive Crit approval of the final diff before any PR. Use when the user invokes herdr-implement or asks to implement an approved Herdr plan. Never create a PR before Crit approval.
---

# Implement, review, then Crit

Use `herdr-projects` for board operations and `ponytail` for implementation.
Follow repository instructions. Projects' AI review and its merge approval are
separate from the human's interactive Crit review.

## Start from an approved plan

1. **Verify the handoff.** Read the exact approved plan, repository instructions,
   acceptance criteria, and checks. If approval or the plan is missing, return
   to `herdr-plan`; do not invent approval. Open the existing board with
   `herdr plugin action invoke open --plugin herdr-projects`.
2. **Prepare one implementation task.** Include the approved plan's full text
   in the task description, not only a temporary file path. Name the repo
   explicitly. A research-only planning task stays research-only: create a
   separate implementation task and reference the planning task/report.
3. **Set the gates before delegating.** On this task set `plan.approve none`,
   `merge.pr false`, `merge.by you`, and `review.when always`. Use Codex for
   `worker.agent` and `reviewer.agent`. Read `show <id>` and verify the effective
   values: task and repo overrides take precedence over global defaults.
4. **Delegate only when implementation is authorized.** Use the approved plan
   as the scope. In a Git repo, use Projects' task worktree and preserve unrelated
   changes. If Projects already launched you as a task worker, implement only
   that task; do not create or delegate another task.
5. **Implement and check.** Make the smallest complete change, run relevant
   checks, and self-review. The worker must leave PR creation disabled and
   return its implementation for Projects' separate AI review. Keep the human
   informed of what passed and what remains.

For a new task, use this shape, substituting the actual repo and approved plan:

```sh
herdr-projects add "Task title" --repo /absolute/repo --desc "Approved plan and acceptance criteria; no PR before final Crit approval." --plan.approve none --merge.pr false --merge.by you --review.when always --worker.agent codex --reviewer.agent codex
herdr-projects show <returned-id>
herdr-projects delegate <returned-id>
```

## Final review and PR gate

1. **Finish the AI review first.** Inspect `details <id>` for checks, findings,
   and the task worktree. Address failed checks and review findings. Do not use
   `approve` or `Ctrl+L` to acknowledge review: those can approve a merge.
2. **Review the final diff with Crit.** In the task worktree, compare against the
   actual PR base and include the complete task diff, including untracked files,
   excluding unrelated changes. Recheck after Projects' commits or rebases.
   Load `crit` for a small change. Load `crit-story` for 10+ files, 500+ changed
   lines, or architecture/public-interface/multi-component behavior changes;
   exclude lockfiles, vendored and generated files from the size threshold.
3. **Complete the human review loop.** Follow the chosen skill, wait for Finish
   Review, address comments, and repeat until Crit reports approval. AI review,
   a generated Story, and silence never count as approval. Any code change
   afterward invalidates approval: rerun checks and Crit on the new final diff.
4. **Create a PR only with authorization and valid Crit approval.** Keep
   `merge.pr false`; create the PR explicitly from the reviewed worktree after
   confirming the diff still matches. Record the reviewed commit/diff, checks,
   and actual Crit approval in the PR description. If Crit is missing or
   unfinished, keep work local and report the blocker.
5. **Leave merging to the human.** Do not enable automatic merging, approve the
   board task, or remove task worktrees as part of PR creation. Report the PR
   and any remaining checks. A separate merge instruction is required.

## Invocation

```text
Use herdr-implement for the approved Fish startup plan. Implement with Codex,
run checks and a separate AI review, then open Crit for me. Do not create a PR
until Crit approves the final diff. After approval, create a draft PR; do not merge.
```
