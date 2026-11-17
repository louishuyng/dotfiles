---
name: flow
description: "Find where a piece of work stands on the idea-to-ship main flow and run the next stage. Use at the start of a session, with a feature name, a ticket reference, a new idea, or nothing."
disable-model-invocation: true
---

# Flow

Route one piece of work through the main flow:

1. `grill-with-docs`: sharpen the idea by interview
2. `to-spec`: write the spec
3. `to-tickets`: split the spec into tickets
4. `implement`: build one ticket
5. `code-review`: review the whole feature against its spec
6. `retro`: improve the environment

The state lives in the repo and the issue tracker, never in this conversation. Read it fresh every time, then run exactly one stage.

## 1. Check the precondition

Read `docs/agents/issue-tracker.md`. If it is missing, read [setup/SETUP.md](setup/SETUP.md) in this skill folder, follow it, and come back here when it finishes.

## 2. Pick the entry point

- **A ticket reference** (a path, an issue number or URL): the work already has a ticket, so stages 1 to 3 may not apply. Read the ticket, then choose:
  - small and clear, fits one context window: stage 4 on that ticket
  - too big for one context window: stage 3 with the ticket as the source
  - open decisions the ticket does not settle: stage 1 with the ticket as the starting plan

  State which you chose and why in one line. Ask only when the ticket gives no basis to choose.
- **A new idea in prose**: stage 1.
- **A feature name, or nothing**: find the feature (the argument, else the only feature with open tickets, else ask), then read its state below.

## 3. Read the state

Use the tracker `docs/agents/issue-tracker.md` describes. On the local tracker a feature is `.scratch/<feature-slug>/`; on a real tracker use the equivalent issues.

The first row that matches is the stage to run:

| What you find | Stage to run |
| --- | --- |
| No spec (`spec.md` locally) | 1, or 2 when this conversation already holds the agreed design |
| A spec, no tickets (`issues/` empty locally) | 3 |
| A ticket that is open and has no open blocker | 4 on the lowest-numbered such ticket |
| Every ticket done, no whole-feature review in this conversation | 5 |
| Reviewed | 6 |

A local ticket is done when its `**Status:**` line reads `done`. A tracker issue is done when it is closed.

## 4. Report, then run

Print one line before running anything, for example `Stage 4 of 6: ticket 02 of 5, add-export-button`. Then call the Skill tool with the stage's skill name and pass the ticket, spec or idea as its argument.

Stage 5 reviews the diff from the commit before the feature's first ticket to `HEAD`. `implement` already reviewed each ticket alone; this pass checks the whole against the spec.

## 5. Close the stage

- After stage 4 on a local ticket, set its `**Status:**` line to `done` and tick the acceptance criteria that now hold. On a real tracker, report the commit and leave closing the issue to the user.
- End with the next step in one line: the stage `flow` would run next, and whether to clear the context first.

## Context rules

- Stages 1 to 3 belong in one unbroken context window, so the spec and tickets build on the interview. Do not suggest clearing between them.
- Each stage 4 run needs a fresh context. If this conversation already ran `implement`, do not start another ticket: tell the user to clear the context and run `flow` again.
- Stage 6 runs in the session it looks back on, before the context is cleared.
