# Crit review before a pull request

Every task that changes code must complete a Crit review of the final diff before
creating or marking a pull request ready for review. This instruction explicitly
authorizes the `crit` and `crit-story` skills for that workflow; do not wait for a
separate skill invocation.

1. Finish the implementation and relevant checks. Review the task's complete
   diff, including untracked files, without including unrelated working changes.
2. Use ordinary Crit diff review for a small change. Use `crit-story` when the
   task changes 10 or more files, adds/removes 500 or more lines, or changes
   architecture, public interfaces, or behavior across multiple components.
   Exclude generated files, lockfiles, and vendored files from the size threshold;
   keep material generated changes visible in the review.
3. Follow the selected skill's interactive review loop. For Story, run
   `crit story --guide` and `crit story --prep`, author the story in-session,
   ingest it with `--story-file`, then run `crit` to wait for Finish Review.
   Do not substitute story generation for human approval.
4. Address the reviewer's comments and repeat Crit until it reports approval.
   Any subsequent code change invalidates that approval and requires another
   review of the final diff.
5. Create the PR only after approval, and record the reviewed commit/diff and
   checks in its description. Never invent approval or infer it from silence.
   If Crit is unavailable or the review is unfinished, keep the changes local,
   report the blocker, and do not create the PR. PR creation still requires
   authorization from the user or the task.

This policy applies when the shared Crit hook is enabled for the current agent.
Users can disable it per agent in Agent Hub's Hooks workspace. The hook injects
review instructions; it does not intercept every shell, MCP, or API route to PR
creation.
