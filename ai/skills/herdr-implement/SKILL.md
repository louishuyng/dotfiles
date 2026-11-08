---
name: herdr-implement
description: Implement a human-approved plan through Herdr Projects using Codex, run checks and AI review, then present the final diff for explicit human approval before any PR. Use when the user invokes herdr-implement or asks to implement an approved Herdr plan. Never create a PR before human approval.
---

# Implement, review, then human approval

Use `herdr-projects` for board operations and `ponytail` for implementation.
Follow repository instructions. Projects' AI review and its merge approval are
separate from the human's review and explicit approval of the final diff.

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
herdr-projects add "Task title" --repo /absolute/repo --desc "Approved plan and acceptance criteria; no PR before explicit human approval of the final diff." --plan.approve none --merge.pr false --merge.by you --review.when always --worker.agent codex --reviewer.agent codex
herdr-projects show <returned-id>
herdr-projects delegate <returned-id>
```

## Final review and PR gate

1. **Finish the AI review first.** Inspect `details <id>` for checks, findings,
   and the task worktree. Address failed checks and review findings. Do not use
   `approve` or `Ctrl+L` to acknowledge review: those can approve a merge.
2. **Present the final diff.** In the task worktree, give the human the base,
   commit, changed files, and checks, plus the exact `git diff` command to
   inspect it. Include only task changes. Recheck the scope after Projects'
   commits or rebases; present the diff again after code changes.
3. **Obtain final human approval.** AI review results are not authorization to
   create a PR. Require the human's explicit approval of the final reviewed
   diff in the agent conversation.
4. **Create a PR only with authorization and valid human approval.** Keep
   `merge.pr false`; create the PR explicitly from the reviewed worktree after
   confirming the diff still matches. Record the reviewed commit/diff, checks,
   and human approval in the PR description. If human review is unfinished, keep
   work local and report the blocker.
5. **Leave merging to the human.** Do not enable automatic merging, approve the
   board task, or remove task worktrees as part of PR creation. Report the PR
   and any remaining checks. A separate merge instruction is required.

## Invocation

```text
Use herdr-implement for the approved Fish startup plan. Implement with Codex,
run checks and a separate AI review, then show me the final diff. Do not create a PR
until I explicitly approve the final diff. After approval, create a draft PR; do not merge.
```
