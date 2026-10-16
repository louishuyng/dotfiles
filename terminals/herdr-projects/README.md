# Herdr Projects

Personal settings live in `config.json`. Link this directory to
`~/.herdr-projects/settings`; the tmux task in `bootstrap/setup.sh` creates that
link. Linking the directory keeps settings managed here when Projects replaces
`config.json` during a settings change. Tasks, reports, and downloaded binaries
stay in `~/.herdr-projects/`.

## Daily use with Codex

### Plan, implement, review, then PR

Start a fresh Codex session after adding the skills so its catalogue refreshes.

1. Invoke `herdr-plan`: it opens the existing Projects board, then plans with
   you in the current Codex chat. Example: `Use herdr-plan to investigate Fish
   startup delays. Propose a small fix; do not implement.`
2. Discuss and explicitly approve the plan. The skill supplies the approved
   text and path; it starts no implementation agents.
3. Invoke `herdr-implement`: `Implement the approved Fish startup plan through
   Projects. Use Codex and a separate AI review. Open Crit when the final diff
   is ready. Create a draft PR only after Crit approval; do not merge.`
4. Review the final diff in Crit, leave comments, and click **Finish Review**.
   The agent addresses feedback and repeats until approved. Later code changes
   require another Crit review.
5. After valid Crit approval, the agent creates the authorized PR and records
   the reviewed commit and checks. Merging remains a separate human decision.

Personal defaults are `plan.approve none`, `merge.pr false`, and `merge.by you`.
Projects' automatic AI review does not count as Crit approval. Keep automatic
PR creation disabled: Projects otherwise opens a draft PR before AI review.
This applies even to draft PRs. Research-only planning tasks stay research-only;
implementation gets a new task containing the approved plan.

The two skills live in [`ai/skills`](../../ai/skills) and are enabled in its
manifest. Agent Hub refreshes managed exports from that shared library.

### Why native plan mode fails on this Mac

Projects 1.0.1 requires bubblewrap (`bwrap`) for its native `plan.approve` mode
in Git repos. Bubblewrap depends on Linux namespaces; installing a macOS shell
wrapper does not provide the required read-only mount. The agreed workflow
plans in Codex instead and delegates implementation with `plan.approve none`.
It uses an agent instruction boundary during planning, not an enforced sandbox.
See [the workflow decision](../../docs/adr/0005-herdr-plan-and-implement.md).

An existing task can override the defaults. After approving its plan outside
Projects, explicitly set `herdr-projects set plan.approve none --task <id>`
before retrying it. Inspect `herdr-projects show <id>` first. Do not change
research-only tasks into implementation tasks, and do not retry unrelated work.

### Workspace and manual board use

The `Projects` workspace holds the board and the `Coordinator` tab. The board
uses Herdr's Gruvbox theme. The sidebar groups agents by workspace and shows
status symbols, task summaries, and progress. Keep this workspace open: closing
it ends the board and coordinator processes. Detach with `ctrl+a`, then `d`
when you want them to keep running.

`config.json` selects Codex for the coordinator, worker, and progress watcher;
the reviewer also defaults to Codex. Settings changes apply when a role next
starts. An existing conversation keeps its chosen program.

1. **Open the board:** press `ctrl+a`, release, then `a`. This returns to the
   running board from any Herdr workspace.
2. **Add a small task:** type the example below and press `Enter`. The
   coordinator adds a task; check its repo and description before delegating.

   ```text
   In /Users/louishuyng/.dotfiles, add a task to explain the Herdr copy-mode
   shortcut in terminals/herdr/README.md. Do not delegate it yet.
   ```

3. **Start Codex:** clear the input, select the task with the arrow keys, and
   press `Tab`. In a Git repo, Projects creates a separate worktree and task
   workspace. Its reviewer runs in that workspace too.
4. **Inspect the work:** with the input empty, press `?`, select the task-panel
   action, and press `Enter`. Press `Enter` on a task to visit its agent;
   `ctrl+a`, then `a` returns to the board. `Space` addresses the selected
   task's agent instead of the coordinator.
5. **Review before merging:** inspect the diff and checks. When the task is
   ready, `ctrl+l` offers approval and merge; read the confirmation and press
   `y` only when you intend to merge. For this dotfiles repo, complete the
   required Crit review before any pull request is created.

For immediate delegation, type this and press `Tab` instead of `Enter`:

```text
In /Users/louishuyng/.dotfiles, research how the Herdr pane-swap script works.
Create a research-only task. Explain its edge cases without changing files.
```

### Aerospace shortcuts

Aerospace owns several Alt keys globally, including `Alt+C/P/T/A/D/J/K`.
Projects 1.0.1 does not expose configurable board shortcuts. Keep the input
empty and press `?`: its action menu lets you select the same actions with
arrow keys and `Enter`, without pressing Alt. Aerospace's bindings stay as-is.

| Key | Use |
| --- | --- |
| `ctrl+a`, then `a` | Open or return to the board |
| `?` with empty input | Action menu, including panel, grouping, archive, and chat display |
| `Enter` / `Tab` with text | Send to coordinator / send and delegate added tasks |
| `Enter` / `Space` with a selected task | Visit its agent / address that agent in the board |
| `ctrl+f` | Find tasks |

### Shell examples

Run these from the repo you want the task to work on:

```sh
herdr-projects add "Document Herdr copy mode" --desc "Explain the copy-mode shortcut in terminals/herdr/README.md. Keep the change small."
herdr-projects list
herdr-projects show --repo .dotfiles
```

Use the id returned by `add`, such as `FLS-1`, to delegate:

```sh
herdr-projects delegate FLS-1
herdr-projects details FLS-1
```

`add` alone starts no agent. Delegation can change files. Automatic PR creation
is disabled in your settings; tasks with an explicit override can still enable
it, so the implementation skill checks each task before delegation. Merging
waits for your approval. Use `--research` when the task should only
produce a report. Agents run with full access by default; use
`herdr-projects set worker.access ask` if you want Codex permission prompts.

## Install

Both the installed Herdr binary and its running server must be 0.9.3 or newer.
Check them separately:

```sh
herdr --version
herdr status server
```

Follow the [Projects setup guide](https://github.com/eliasstravik/herdr-projects/blob/main/docs/get-started.md):

1. Run `herdr plugin install eliasstravik/herdr-projects`.
2. Find the checkout with `herdr plugin list`, then run
   `sh <checkout>/bin/run.sh install` to create the shell launcher.
3. Start a new Fish shell; `terminals/fish/env/init.fish` adds
   `~/.herdr-projects/data/bin` to PATH.
4. Run `herdr-projects doctor`.
5. Press `ctrl+a`, then `a` to open the board. The binding lives in
   `terminals/herdr/config.toml`.

## Installed version differs from the server

Updating the binary can leave an older server running. Projects refuses servers
older than 0.9.3 even when `herdr --version` reports a newer version.

Save work before a normal restart: `herdr server stop` ends the server's pane
processes. Run it from a terminal outside Herdr, then run `herdr` to start the
installed version. Detaching and reattaching alone does not update the server.

Direct installs also offer experimental `herdr update --handoff`, which tries to
preserve live processes. See [Herdr session state and restore](https://github.com/herdrdev/herdr/blob/v0.9.5/docs/next/website/src/content/docs/session-state.mdx).
