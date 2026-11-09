# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_grok_global_optspecs
	string join \n v/version cwd= add-dir= leader-socket= debug debug-file= always-approve trust allow= deny= p/single= prompt-json= prompt-file= verbatim output-format= include-partial-messages json-schema= m/model= reasoning-effort= rules= compaction-mode= compaction-detail= system-prompt-override= r/resume= load= c/continue s/session-id= fork-session w/worktree= worktree-ref= restore-code no-plan no-subagents no-ask-user experimental-memory no-memory memory-flush agent= agents= tools= disallowed-tools= header= exclude-workspace-context endless-retries retry-all-inference-errors harness= conversation-history-file= mode= max-turns= permission-mode= disable-web-search no-wait-for-background background-wait-timeout= background-shell-timeout= sandbox= storage-mode= client-identifier= hunk-tracker-mode= terminal fs-read fs-write no-auto-update todo-gate installer= no-alt-screen minimal fullscreen log-sampling force-login oauth leader no-leader h/help
end

function __fish_grok_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_grok_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_grok_using_subcommand
	set -l cmd (__fish_grok_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c grok -n "__fish_grok_needs_command" -l cwd -d 'Working directory' -r -F
complete -c grok -n "__fish_grok_needs_command" -l add-dir -d 'Also work in this folder, beside the working directory (repeatable)' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_needs_command" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_needs_command" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_needs_command" -l allow -d 'Permission allow rule (compat aliases: --allowedTools, --allowed-tools)' -r
complete -c grok -n "__fish_grok_needs_command" -l deny -d 'Permission deny rule (compat alias: --disallowedTools)' -r
complete -c grok -n "__fish_grok_needs_command" -s p -l single -d 'Single-turn prompt. Prints the response to stdout and exits' -r
complete -c grok -n "__fish_grok_needs_command" -l prompt-json -d 'Single-turn prompt as JSON content blocks' -r
complete -c grok -n "__fish_grok_needs_command" -l prompt-file -d 'Single-turn prompt from a file' -r -F
complete -c grok -n "__fish_grok_needs_command" -l output-format -d 'Output format for headless mode' -r -f -a "plain\t''
json\t''
streaming-json\t'NDJSON: one ACP session update per line, the agent\'s native format'
streaming-messages-json\t'NDJSON in the Anthropic Messages API wire format'"
complete -c grok -n "__fish_grok_needs_command" -l json-schema -d 'JSON Schema for structured output' -r
complete -c grok -n "__fish_grok_needs_command" -s m -l model -d 'Model ID to use' -r
complete -c grok -n "__fish_grok_needs_command" -l reasoning-effort -l effort -d 'Reasoning effort for reasoning models' -r
complete -c grok -n "__fish_grok_needs_command" -l rules -d 'Extra rules to append to the system prompt' -r
complete -c grok -n "__fish_grok_needs_command" -l compaction-mode -d 'Compaction mode [summary|transcript|segments]. `summary` adds no pointer; `transcript` points at the raw transcript; `segments` (default) persists per-segment markdown to grep. Sets `GROK_COMPACTION_MODE`' -r
complete -c grok -n "__fish_grok_needs_command" -l compaction-detail -d 'Segments verbatim detail [none|minimal|balanced|verbose] (default `verbose`). Only affects `--compaction-mode segments`. Sets `GROK_COMPACTION_DETAIL`' -r
complete -c grok -n "__fish_grok_needs_command" -l system-prompt-override -d 'Override the agent\'s system prompt (compat alias: --system-prompt)' -r
complete -c grok -n "__fish_grok_needs_command" -s r -l resume -d 'Resume a session by ID or title, or the most recent if omitted' -r
complete -c grok -n "__fish_grok_needs_command" -l load -d 'Resume a previous session by session ID (alias for --resume)' -r
complete -c grok -n "__fish_grok_needs_command" -s s -l session-id -d 'Use a specific session UUID for a new conversation' -r
complete -c grok -n "__fish_grok_needs_command" -s w -l worktree -d 'Start the session in a new git worktree, optionally named' -r
complete -c grok -n "__fish_grok_needs_command" -l worktree-ref -l ref -d 'Branch, tag, or commit to base the worktree on (with `--worktree`)' -r
complete -c grok -n "__fish_grok_needs_command" -l agent -d 'Agent name or definition file path' -r
complete -c grok -n "__fish_grok_needs_command" -l agents -d 'Inline subagent definitions as JSON' -r
complete -c grok -n "__fish_grok_needs_command" -l tools -d 'Built-in tools to allow (comma-separated)' -r
complete -c grok -n "__fish_grok_needs_command" -l disallowed-tools -d 'Built-in tools to remove (comma-separated)' -r
complete -c grok -n "__fish_grok_needs_command" -l header -d 'Header to add to each turn\'s model requests, as \'Name: Value\' (headless, daemon sessions only). Repeatable' -r
complete -c grok -n "__fish_grok_needs_command" -l harness -d 'Internal harness override for each turn (headless, daemon sessions only)' -r
complete -c grok -n "__fish_grok_needs_command" -l conversation-history-file -d 'File of prior messages the first prompt carries (headless, daemon sessions only)' -r -F
complete -c grok -n "__fish_grok_needs_command" -l mode -d 'Conversation mode the session starts in (headless, daemon sessions only)' -r -f -a "ask\t'Read-only questions and answers'"
complete -c grok -n "__fish_grok_needs_command" -l max-turns -d 'Maximum number of agent turns' -r
complete -c grok -n "__fish_grok_needs_command" -l permission-mode -d 'Permission mode' -r -f -a "default\t''
acceptEdits\t''
auto\t''
dontAsk\t''
bypassPermissions\t''
plan\t''"
complete -c grok -n "__fish_grok_needs_command" -l background-wait-timeout -d 'Max seconds to wait for background work after the latest turn ends, or in daemon sessions after the prompt\'s turn ends (headless only). Applies to bash/monitor `task_completed` and background subagents (`SubagentFinished`); a follow-up turn one of those completions starts runs to its end and restarts the clock. In daemon sessions the clock keeps running through the turns the agent runs after the prompt. When the wait runs out with background work or such a turn still running, the run stops the background work and exits 1; exit stops the turn as well, unless the run shares Grok\'s background service with other windows. Persistent `monitor(persistent:true)` never completes and always waits the full timeout. When given, this also bounds how long the run waits on an active goal. When unset, the run waits on an active goal until the goal ends' -r
complete -c grok -n "__fish_grok_needs_command" -l background-shell-timeout -d 'Max seconds background shells may run after the latest turn ends with no follow-up turn or background end since (headless, daemon sessions only). When it runs out, the shells are stopped without follow-up turns and the run keeps waiting on background subagents, with no limit. The run still succeeds. Unlike `--background-wait-timeout`, this sets no overall limit and does not bound an active goal' -r
complete -c grok -n "__fish_grok_needs_command" -l sandbox -d 'Sandbox profile for filesystem and network access' -r
complete -c grok -n "__fish_grok_needs_command" -l storage-mode -d 'Session storage mode: local or writeback' -r
complete -c grok -n "__fish_grok_needs_command" -l client-identifier -d 'Override the client identifier sent to the agent' -r
complete -c grok -n "__fish_grok_needs_command" -l hunk-tracker-mode -d 'Hunk tracker mode: agent_only, all_dirty, or off ("disabled" is an alias for off, which turns the hunk tracker off entirely)' -r
complete -c grok -n "__fish_grok_needs_command" -l installer -d 'Set the installer field in config.toml' -r
complete -c grok -n "__fish_grok_needs_command" -s v -l version -d 'Print version'
complete -c grok -n "__fish_grok_needs_command" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_needs_command" -l always-approve -d 'Auto-approve all tool executions'
complete -c grok -n "__fish_grok_needs_command" -l trust -d 'Trust this folder and persist the decision to the trust store'
complete -c grok -n "__fish_grok_needs_command" -l verbatim -d 'Send the prompt exactly as given'
complete -c grok -n "__fish_grok_needs_command" -l include-partial-messages -d 'Emit incremental text and thinking deltas alongside whole messages'
complete -c grok -n "__fish_grok_needs_command" -s c -l continue -d 'Continue the most recent session for the current working directory'
complete -c grok -n "__fish_grok_needs_command" -l fork-session -d 'When resuming, create a new session ID instead of reusing the original'
complete -c grok -n "__fish_grok_needs_command" -l restore-code -d 'Restore the original session\'s repository snapshot when resuming'
complete -c grok -n "__fish_grok_needs_command" -l no-plan -d 'Disable plan mode'
complete -c grok -n "__fish_grok_needs_command" -l no-subagents -d 'Disable subagent spawning'
complete -c grok -n "__fish_grok_needs_command" -l no-ask-user -d 'Disable structured question prompts from the agent'
complete -c grok -n "__fish_grok_needs_command" -l experimental-memory -d 'Legacy compatibility flag for enabling cross-session memory'
complete -c grok -n "__fish_grok_needs_command" -l no-memory -d 'Legacy compatibility flag for disabling cross-session memory'
complete -c grok -n "__fish_grok_needs_command" -l memory-flush -d 'Run a memory flush after the headless turn (or instead of a prompt when resuming). Calls `x.ai/memory/flush` and waits for capture of finished turns. Headless only: `/flush` as `-p` text is not a reliable flush trigger'
complete -c grok -n "__fish_grok_needs_command" -l exclude-workspace-context -d 'Leave rules, skills, transcripts and notes out of each turn (headless, daemon sessions only)'
complete -c grok -n "__fish_grok_needs_command" -l endless-retries -d 'Retry retriable errors without a limit (headless, daemon sessions only)'
complete -c grok -n "__fish_grok_needs_command" -l retry-all-inference-errors -d 'Also retry inference errors the server marks non-retriable (headless, daemon sessions only)'
complete -c grok -n "__fish_grok_needs_command" -l disable-web-search -d 'Disable web search and web fetch tools'
complete -c grok -n "__fish_grok_needs_command" -l no-wait-for-background -d 'Exit as soon as the first agent turn ends, without waiting for pending background bash/monitor tasks, background subagents, or the follow-up turns their completions start (headless only). Use this for fast scripts that only need the first turn\'s text. The work this exit stops does not change the exit code'
complete -c grok -n "__fish_grok_needs_command" -l terminal -d 'Enable terminal support for the agent'
complete -c grok -n "__fish_grok_needs_command" -l fs-read -d 'Enable client-side file reads'
complete -c grok -n "__fish_grok_needs_command" -l fs-write -d 'Enable client-side file writes'
complete -c grok -n "__fish_grok_needs_command" -l no-auto-update -d 'Disable automatic updates for this session'
complete -c grok -n "__fish_grok_needs_command" -l todo-gate -d 'Enable the runtime turn-end TodoGate for this session. Session-scoped (not persisted). Highest precedence: overrides remote `todo_gate_enabled` and the built-in default (which is `false`)'
complete -c grok -n "__fish_grok_needs_command" -l no-alt-screen -d 'Run inline instead of using the terminal alternate screen'
complete -c grok -n "__fish_grok_needs_command" -l minimal -d 'Experimental: scrollback-native rendering'
complete -c grok -n "__fish_grok_needs_command" -l fullscreen -d 'Open in the standard fullscreen TUI for this session'
complete -c grok -n "__fish_grok_needs_command" -l log-sampling -d 'Write sampling events to ~/.grok/logs/sampling.jsonl'
complete -c grok -n "__fish_grok_needs_command" -l force-login -d 'Show the login screen even when credentials are already available'
complete -c grok -n "__fish_grok_needs_command" -l oauth -d 'Force browser (loopback) login when the welcome screen authenticates'
complete -c grok -n "__fish_grok_needs_command" -l leader -d 'Connect to a shared leader process'
complete -c grok -n "__fish_grok_needs_command" -l no-leader -d 'Run standalone even when leader mode is configured'
complete -c grok -n "__fish_grok_needs_command" -s h -l help -d 'Print help (see more with \'grok help\')'
complete -c grok -n "__fish_grok_needs_command" -a "agent" -d 'Run Grok without the interactive UI'
complete -c grok -n "__fish_grok_needs_command" -a "inspect" -d 'Show the configuration Grok discovers for this directory'
complete -c grok -n "__fish_grok_needs_command" -a "doctor" -d 'Check terminal, clipboard, color, and input support without starting Grok'
complete -c grok -n "__fish_grok_needs_command" -a "leader" -d 'Manage running leader processes'
complete -c grok -n "__fish_grok_needs_command" -a "logout" -d 'Sign out and clear cached credentials'
complete -c grok -n "__fish_grok_needs_command" -a "login" -d 'Sign in to Grok'
complete -c grok -n "__fish_grok_needs_command" -a "mcp" -d 'Manage MCP server configurations'
complete -c grok -n "__fish_grok_needs_command" -a "plugin" -d 'Manage plugins and marketplace sources'
complete -c grok -n "__fish_grok_needs_command" -a "memory" -d 'Manage cross-session memory'
complete -c grok -n "__fish_grok_needs_command" -a "models" -d 'List available models and exit'
complete -c grok -n "__fish_grok_needs_command" -a "sessions" -d 'List, search, or restore sessions'
complete -c grok -n "__fish_grok_needs_command" -a "usage" -d 'Print your plan\'s usage limit, or a session\'s persisted token and cost usage'
complete -c grok -n "__fish_grok_needs_command" -a "setup" -d 'Fetch and install managed configuration'
complete -c grok -n "__fish_grok_needs_command" -a "wrap" -d 'Run any command with local clipboard support'
complete -c grok -n "__fish_grok_needs_command" -a "export" -d 'Export a session transcript as Markdown'
complete -c grok -n "__fish_grok_needs_command" -a "trace" -d 'Export or upload session trace data'
complete -c grok -n "__fish_grok_needs_command" -a "update" -d 'Check for updates or install a specific version'
complete -c grok -n "__fish_grok_needs_command" -a "version" -d 'Print version information'
complete -c grok -n "__fish_grok_needs_command" -a "v" -d 'Print version information'
complete -c grok -n "__fish_grok_needs_command" -a "completions" -d 'Generate shell completion scripts (bash, zsh, fish, powershell, ...)'
complete -c grok -n "__fish_grok_needs_command" -a "worktree" -d 'Manage git worktrees'
complete -c grok -n "__fish_grok_needs_command" -a "clone" -d 'Lazy-clone a git repository via grove (NFS on macOS, FUSE on Linux)'
complete -c grok -n "__fish_grok_needs_command" -a "du" -d 'Show what the grok home (~/.grok) uses on disk'
complete -c grok -n "__fish_grok_needs_command" -a "disk-usage" -d 'Show what the grok home (~/.grok) uses on disk'
complete -c grok -n "__fish_grok_needs_command" -a "workspace" -d 'Expose this workspace to the Computer Hub (via the leader)'
complete -c grok -n "__fish_grok_needs_command" -a "cursor-worker" -d 'Register this machine as a Cursor private worker (via the leader)'
complete -c grok -n "__fish_grok_needs_command" -a "worker" -d 'Run this machine as a Cursor private worker'
complete -c grok -n "__fish_grok_needs_command" -a "dashboard" -d 'Open the Agent Dashboard view at startup'
complete -c grok -n "__fish_grok_needs_command" -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -s m -l model -d 'Model ID to use' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l reasoning-effort -l effort -d 'Reasoning effort for reasoning models' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l agent-profile -d 'Path to an agent profile file' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l plugin-dir -d 'Load a plugin from this directory for this process only (repeatable)' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l grok-ws-origin -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l grok-ws-url -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l cli-chat-proxy-base-url -d 'Override the CLI chat proxy base URL' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l xai-api-base-url -d 'Override the public xAI API base URL' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l reauth -l --reauthenticate -d 'Run authentication before starting the agent'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l always-approve -d 'Auto-approve all tool executions'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l leader -d 'Connect to a shared leader process instead of starting a new agent'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l no-leader -d 'Start a new agent even when config enables leader mode'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -s h -l help -d 'Print help (see more with \'grok help agent\')'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -f -a "stdio" -d 'Run the agent over stdio'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -f -a "headless" -d 'Run the agent headlessly over the Grok WebSocket relay'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -f -a "serve" -d 'Run the agent as a WebSocket server'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -f -a "leader" -d 'Run as the shared leader process for other clients'
complete -c grok -n "__fish_grok_using_subcommand agent; and not __fish_seen_subcommand_from stdio headless serve leader help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from stdio" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from stdio" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from stdio" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from stdio" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -l grok-ws-origin -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -l grok-ws-url -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from headless" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l bind -d 'Address for the server to listen on' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l secret -d 'Secret token for client authentication (auto-generated if not provided)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l remote -d 'Remote agent URL for proxy mode' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l grok-ws-origin -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l grok-ws-url -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from serve" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-pool -d 'Team Self-Hosted Pool the worker joins (`grok worker --pool`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-pool-name -d '`grok worker --pool-name`' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-labels-file -d 'JSON or TOML file of worker labels' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-api-key -d 'Cursor API key the worker registers with (`grok worker --api-key`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-auth-token-file -d 'File holding the worker\'s Cursor auth token (`grok worker --auth-token-file`)' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-id -d 'Worker id a pool supervisor assigned (`grok worker --worker-id`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-on-session-start -d 'Command run once a pool claim lands (`grok worker --on-session-start`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-on-session-end -d 'Command run before a pool claim is torn down (`grok worker --on-session-end`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-management-addr -d 'Worker health server address (`grok worker --management-addr`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-mcp-tool-timeout -d 'Tool-call timeouts for claim stdio MCP servers (`grok worker --mcp-tool-timeout`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-idle-release-timeout -d 'Seconds before Cursor releases an idle claim (`grok worker --idle-release-timeout`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-data-dir -d 'Directory for the worker\'s state (`grok worker --data-dir`)' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-wait -d 'Wait for a running leader to stop (`grok worker --wait`)' -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l grok-ws-origin -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l grok-ws-url -r
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l no-exit-on-disconnect -d 'Keep the leader running after the last client disconnects'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l relay-on-demand -d 'Defer the grok.com relay WebSocket until the first headless IPC client registers'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l no-auto-update -d 'Disable periodic auto-update checks for the leader'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker -d 'Register this leader as a Cursor private worker once it is ready'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-single-use -d '`grok worker --single-use`'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-mint-github-token -d '`grok worker --mint-github-token`'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-sync-dashboard-secrets -d '`grok worker --sync-dashboard-secrets`'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-clone-git-repos -d '`grok worker --clone-git-repos`'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-identity-socket -d 'Per-claim OIDC identity sockets (`grok worker --identity-socket`)'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l cursor-worker-run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on a pool worker (`grok worker --run-mcp-servers`)'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from leader" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from help" -f -a "stdio" -d 'Run the agent over stdio'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from help" -f -a "headless" -d 'Run the agent headlessly over the Grok WebSocket relay'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from help" -f -a "serve" -d 'Run the agent as a WebSocket server'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from help" -f -a "leader" -d 'Run as the shared leader process for other clients'
complete -c grok -n "__fish_grok_using_subcommand agent; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand inspect" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand inspect" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand inspect" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand inspect" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand inspect" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -l json -d 'Print the diagnostic report as JSON'
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -s h -l help -d 'Print help (see more with \'grok help doctor\')'
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -f -a "fix" -d 'Apply an automatic fix'
complete -c grok -n "__fish_grok_using_subcommand doctor; and not __fish_seen_subcommand_from fix help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from fix" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from fix" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from fix" -l yes -d 'Apply the displayed changes without confirmation'
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from fix" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from fix" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from help" -f -a "fix" -d 'Apply an automatic fix'
complete -c grok -n "__fish_grok_using_subcommand doctor; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -s h -l help -d 'Print help (see more with \'grok help leader\')'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -f -a "list" -d 'List running leader processes'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -f -a "info" -d 'Show details for a leader process'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -f -a "kill" -d 'Stop all running leader processes'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -f -a "worker" -d 'Run the same commands as `grok worker`'
complete -c grok -n "__fish_grok_using_subcommand leader; and not __fish_seen_subcommand_from list info kill worker help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from info" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from kill" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from kill" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from kill" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from kill" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -s h -l help -d 'Print help (see more with \'grok help leader worker\')'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "start" -d 'Run a leader in this terminal until Ctrl+C'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "list" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "controller" -d 'Claim pending Cloud Agent requests for team pools and run a spawn hook for each'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from worker" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from help" -f -a "list" -d 'List running leader processes'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from help" -f -a "info" -d 'Show details for a leader process'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from help" -f -a "kill" -d 'Stop all running leader processes'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from help" -f -a "worker" -d 'Run the same commands as `grok worker`'
complete -c grok -n "__fish_grok_using_subcommand leader; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand logout" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand logout" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand logout" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand logout" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand login" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand login" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand login" -l legacy -d 'Ignored (kept for backwards compatibility). OAuth2 is now the only auth method'
complete -c grok -n "__fish_grok_using_subcommand login" -l oauth -d 'Force browser (loopback) login instead of device-code authentication'
complete -c grok -n "__fish_grok_using_subcommand login" -l device-auth -l device-code -d 'Use device-code authentication for headless/remote environments'
complete -c grok -n "__fish_grok_using_subcommand login" -l devbox -d 'Authenticate for remote development environments (hidden). Field is always present so match arms stay feature-unification-safe; clap registers `--devbox` only when that feature is enabled (`arg(skip)` otherwise → always false)'
complete -c grok -n "__fish_grok_using_subcommand login" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand login" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -s h -l help -d 'Print help (see more with \'grok help mcp\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "list" -d 'List configured MCP servers'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "add" -d 'Add or update an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "remove" -d 'Remove an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "enable" -d 'Enable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "disable" -d 'Disable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "doctor" -d 'Diagnose MCP server configuration and connectivity'
complete -c grok -n "__fish_grok_using_subcommand mcp; and not __fish_seen_subcommand_from list add remove enable disable doctor help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -s t -l transport -d 'Transport type' -r -f -a "stdio\t'Launch a local process and communicate over stdin/stdout'
http\t'Connect to a remote server over streamable HTTP'
sse\t'Connect to a remote server over Server-Sent Events'"
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -s s -l scope -d 'Config to write to: user (~/.grok/config.toml) or project (./.grok/config.toml)' -r -f -a "user\t'`~/.grok/config.toml`, available in all your projects'
project\t'`./.grok/config.toml`, shared with everyone working in this directory'"
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -s e -l env -d 'Environment variable for the server process (repeatable)' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -s H -l header -d 'HTTP header for remote servers (repeatable)' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l command -d 'Legacy alias for the positional command argument' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l args -d 'Legacy companion to --command' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l url -d 'Legacy alias for adding a remote server by URL' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l type -d 'Legacy transport type for --url servers' -r
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from add" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from remove" -s s -l scope -d 'Config to remove from. When omitted, all scopes are searched' -r -f -a "user\t'`~/.grok/config.toml`, available in all your projects'
project\t'`./.grok/config.toml`, shared with everyone working in this directory'"
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from remove" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from remove" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from remove" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from enable" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from enable" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from enable" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from disable" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from disable" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from disable" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from doctor" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from doctor" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from doctor" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from doctor" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from doctor" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "list" -d 'List configured MCP servers'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "add" -d 'Add or update an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "remove" -d 'Remove an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "enable" -d 'Enable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "disable" -d 'Disable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "doctor" -d 'Diagnose MCP server configuration and connectivity'
complete -c grok -n "__fish_grok_using_subcommand mcp; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -s h -l help -d 'Print help (see more with \'grok help plugin\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "list" -d 'List installed plugins'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "install" -d 'Install a plugin from a git URL or local path'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "uninstall" -d 'Uninstall an installed plugin by name'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "rm" -d 'Uninstall an installed plugin by name'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "remove" -d 'Uninstall an installed plugin by name'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "update" -d 'Update installed plugin(s)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "enable" -d 'Enable a disabled plugin'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "disable" -d 'Disable a plugin without uninstalling it'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "details" -d 'Show a plugin\'s component inventory'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "validate" -d 'Validate a plugin manifest'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "tag" -d 'Create a release git tag from the plugin\'s manifest version'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "marketplace" -d 'Manage marketplace sources'
complete -c grok -n "__fish_grok_using_subcommand plugin; and not __fish_seen_subcommand_from list install uninstall rm remove update enable disable details validate tag marketplace help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -l available -d 'Include available plugins from marketplace sources. Requires --json'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from install" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from install" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from install" -l trust -d 'Trust the plugin immediately (skip confirmation prompt)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from install" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l confirm -d 'Skip confirmation for multi-plugin repos'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l keep-data -d 'Preserve the plugin\'s persistent data directory'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from uninstall" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -l confirm -d 'Skip confirmation for multi-plugin repos'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -l keep-data -d 'Preserve the plugin\'s persistent data directory'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from rm" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l confirm -d 'Skip confirmation for multi-plugin repos'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l keep-data -d 'Preserve the plugin\'s persistent data directory'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from update" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from update" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from update" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from enable" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from enable" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from enable" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from disable" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from disable" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from disable" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from details" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from details" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from details" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from details" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from validate" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from validate" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from validate" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from validate" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -l push -d 'Push the tag to the remote after creating it'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -s f -l force -d 'Create the tag even if the working tree is dirty or tag exists'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -l dry-run -d 'Print what would be tagged without creating the tag'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from tag" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -s h -l help -d 'Print help (see more with \'grok help plugin marketplace\')'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "list" -d 'List configured marketplace sources and their plugins'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "add" -d 'Add a marketplace source (git URL, GitHub shorthand, or local path)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "remove" -d 'Remove a marketplace source and uninstall its plugins'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "update" -d 'Refresh marketplace source(s) and sync git caches'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from marketplace" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "list" -d 'List installed plugins'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "install" -d 'Install a plugin from a git URL or local path'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "uninstall" -d 'Uninstall an installed plugin by name'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "update" -d 'Update installed plugin(s)'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "enable" -d 'Enable a disabled plugin'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "disable" -d 'Disable a plugin without uninstalling it'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "details" -d 'Show a plugin\'s component inventory'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "validate" -d 'Validate a plugin manifest'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "tag" -d 'Create a release git tag from the plugin\'s manifest version'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "marketplace" -d 'Manage marketplace sources'
complete -c grok -n "__fish_grok_using_subcommand plugin; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -s h -l help -d 'Print help (see more with \'grok help memory\')'
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -f -a "clear" -d 'Clear memory files (workspace by default)'
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -f -a "serve" -d 'Serve memory to this user\'s grok processes over a local socket until idle'
complete -c grok -n "__fish_grok_using_subcommand memory; and not __fish_seen_subcommand_from clear serve help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l workspace -d 'Clear workspace-scoped memory (the whole workspace scope directory)'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l global -d 'Clear global memory (the whole global scope directory)'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l all -d 'Clear both workspace and global memory'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -s y -l yes -d 'Skip confirmation prompt'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from clear" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from serve" -l socket -d 'Socket to serve on; defaults to the grok home\'s memory server socket. Its directory is created owner-only (0700) when missing and must be owner-only when it exists' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from serve" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from serve" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from serve" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from serve" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from help" -f -a "clear" -d 'Clear memory files (workspace by default)'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from help" -f -a "serve" -d 'Serve memory to this user\'s grok processes over a local socket until idle'
complete -c grok -n "__fish_grok_using_subcommand memory; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand models" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand models" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand models" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand models" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -s h -l help -d 'Print help (see more with \'grok help sessions\')'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -f -a "list" -d 'List recent sessions (same as search with no query)'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -f -a "search" -d 'Search sessions by keyword'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -f -a "delete" -d 'Permanently delete a session from history'
complete -c grok -n "__fish_grok_using_subcommand sessions; and not __fish_seen_subcommand_from list search delete help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from list" -s n -l limit -d 'Maximum number of sessions to show' -r
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from search" -s n -l limit -d 'Maximum number of sessions to show' -r
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from search" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from search" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from search" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from search" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from delete" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from delete" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from delete" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from delete" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from help" -f -a "list" -d 'List recent sessions (same as search with no query)'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from help" -f -a "search" -d 'Search sessions by keyword'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from help" -f -a "delete" -d 'Permanently delete a session from history'
complete -c grok -n "__fish_grok_using_subcommand sessions; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand usage" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand usage" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand usage" -l json -d 'Print the plan\'s usage limit as JSON'
complete -c grok -n "__fish_grok_using_subcommand usage" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand usage" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand setup" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand setup" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand setup" -l json -d 'Print the fetched configuration as JSON instead of installing it'
complete -c grok -n "__fish_grok_using_subcommand setup" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand setup" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand wrap" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand wrap" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand wrap" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand wrap" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand export" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand export" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand export" -s c -l clipboard -d 'Copy to clipboard instead of writing to stdout'
complete -c grok -n "__fish_grok_using_subcommand export" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand export" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand trace" -s o -l output -d 'Output path, which must not exist yet' -r -F
complete -c grok -n "__fish_grok_using_subcommand trace" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand trace" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand trace" -l local -d 'Save locally only, skip remote upload'
complete -c grok -n "__fish_grok_using_subcommand trace" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand trace" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand trace" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand update" -l version -d 'Install a specific version (e.g. 0.1.150 or 0.1.151-alpha.2)' -r
complete -c grok -n "__fish_grok_using_subcommand update" -l channel -d 'Switch to a custom channel config defines' -r
complete -c grok -n "__fish_grok_using_subcommand update" -l trigger -d 'Internal: what spawned this `grok update` (`user_command`, `auto_background`, `leader_converge`). Hidden' -r
complete -c grok -n "__fish_grok_using_subcommand update" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand update" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand update" -l check -d 'Check for updates without installing'
complete -c grok -n "__fish_grok_using_subcommand update" -l json -d 'Emit machine-readable JSON output (for --check)'
complete -c grok -n "__fish_grok_using_subcommand update" -l force-reinstall -d 'Force re-download and install even if already up to date'
complete -c grok -n "__fish_grok_using_subcommand update" -l alpha -d 'Switch to the alpha release channel (faster updates, may have bugs)'
complete -c grok -n "__fish_grok_using_subcommand update" -l stable -d 'Switch to the stable release channel (default, weekly releases)'
complete -c grok -n "__fish_grok_using_subcommand update" -l enterprise -d 'Switch to the enterprise release channel'
complete -c grok -n "__fish_grok_using_subcommand update" -l legacy-alpha -d 'Switch to the native alpha build and stay off the unified rollout'
complete -c grok -n "__fish_grok_using_subcommand update" -l legacy-stable -d 'Switch to the native stable build and stay off the unified rollout'
complete -c grok -n "__fish_grok_using_subcommand update" -l auto -d 'Internal compat alias for `--trigger=auto_background` (older parents still spawn children with it)'
complete -c grok -n "__fish_grok_using_subcommand update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand update" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand version" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand version" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand version" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand version" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand version" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand v" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand v" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand v" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand v" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand v" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand completions" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand completions" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand completions" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand completions" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -s h -l help -d 'Print help (see more with \'grok help worktree\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "create" -d 'Create a worktree the way `grok -w` does, without starting a session'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "list" -d 'List the registry\'s worktrees, unfinished copies and Grove clones'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "ls" -d 'List the registry\'s worktrees, unfinished copies and Grove clones'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "show" -d 'Show details for a specific worktree'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "rm" -d 'Remove worktrees, or Grove clones through the daemon that owns them'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "gc" -d 'Remove expired worktrees, keeping any whose work would not survive'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "detach" -d 'Convert a Grove-projected worktree into a plain git worktree'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "salvage" -d 'Recover a Grove worktree\'s hydrated and dirty files when its source repo is gone'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "clean-artifacts" -d 'Purge escape-dir artifact contents (`git clean` does not)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "redirect" -d 'Inspect and repair artifact-directory redirections'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "db" -d 'Database maintenance'
complete -c grok -n "__fish_grok_using_subcommand worktree; and not __fish_seen_subcommand_from create list ls show rm gc detach salvage clean-artifacts redirect db help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from create" -l ref -d 'Branch, tag, or commit to base the worktree on' -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from create" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from create" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from create" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from create" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l repo -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l type -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l json
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l all
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l repo -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l type -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l json
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l all
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from ls" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from show" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from show" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from show" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from show" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -s f -l force -d 'Remove a worktree even when it is in use or has unsaved work'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -l dry-run
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -l keep-store -d 'For a Grove clone: unmount and forget it, but leave its store on disk'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from rm" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -l max-age -d 'Expire worktrees idle longer than this, e.g. `7d`. Without it, nothing expires' -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -l dry-run -d 'Report what would be removed without removing it'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -s f -l force -d 'Skip the live-process, open-session and protected-path guards'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from gc" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from detach" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from detach" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from detach" -l allow-copy -d 'Permit a copy when dest and backing are on different devices'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from detach" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from detach" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from salvage" -l out -d 'Directory to write the salvaged plain repo into' -r
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from salvage" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from salvage" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from salvage" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from salvage" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -l dry-run -d 'List jail children and exit without deleting'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -l yes -d 'Required to actually delete (irreversible)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from clean-artifacts" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -s h -l help -d 'Print help (see more with \'grok help worktree redirect\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "list" -d 'Print the mount\'s effective redirect entries'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "add" -d 'Declare a user redirect and apply it'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "del" -d 'Remove a user redirect or exclude an automatic redirect'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "fixup" -d 'Apply the mount\'s redirect policy and reopen a closed redirect gate'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "unmount" -d 'Take down one redirect object, or every redirect object on the mount'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from redirect" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -s h -l help -d 'Print help (see more with \'grok help worktree db\')'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -f -a "rebuild" -d 'Rebuild DB from filesystem scan'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -f -a "stats" -d 'Show DB statistics'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -f -a "path" -d 'Print DB file path'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from db" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "create" -d 'Create a worktree the way `grok -w` does, without starting a session'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "list" -d 'List the registry\'s worktrees, unfinished copies and Grove clones'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "show" -d 'Show details for a specific worktree'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "rm" -d 'Remove worktrees, or Grove clones through the daemon that owns them'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "gc" -d 'Remove expired worktrees, keeping any whose work would not survive'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "detach" -d 'Convert a Grove-projected worktree into a plain git worktree'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "salvage" -d 'Recover a Grove worktree\'s hydrated and dirty files when its source repo is gone'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "clean-artifacts" -d 'Purge escape-dir artifact contents (`git clean` does not)'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "redirect" -d 'Inspect and repair artifact-directory redirections'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "db" -d 'Database maintenance'
complete -c grok -n "__fish_grok_using_subcommand worktree; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand clone" -s b -l branch -d 'Branch or ref to check out' -r
complete -c grok -n "__fish_grok_using_subcommand clone" -l redirect-dir -d 'Enable redirects with the safe directory allowlist plus these extras' -r
complete -c grok -n "__fish_grok_using_subcommand clone" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand clone" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand clone" -l full-history -d 'Fetch complete history during clone instead of the fast depth-1 bootstrap'
complete -c grok -n "__fish_grok_using_subcommand clone" -l redirect-ignored -d 'Enable redirects for the safe artifact-directory allowlist'
complete -c grok -n "__fish_grok_using_subcommand clone" -l no-redirects -d 'Explicitly disable redirects for this clone'
complete -c grok -n "__fish_grok_using_subcommand clone" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand clone" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand du" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand du" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand du" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand du" -l clean -d 'Ask the Grove daemon to purge redirect contents and orphan jails'
complete -c grok -n "__fish_grok_using_subcommand du" -l clean-orphaned -d 'Ask the Grove daemon to delete only ownership-proven orphan redirect jails'
complete -c grok -n "__fish_grok_using_subcommand du" -l yes -d 'Confirm an irreversible redirect cleanup'
complete -c grok -n "__fish_grok_using_subcommand du" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand du" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l clean -d 'Ask the Grove daemon to purge redirect contents and orphan jails'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l clean-orphaned -d 'Ask the Grove daemon to delete only ownership-proven orphan redirect jails'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l yes -d 'Confirm an irreversible redirect cleanup'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand disk-usage" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -s h -l help -d 'Print help (see more with \'grok help workspace\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "start" -d 'Start (or update) the workspace-to-hub exposure'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "pause" -d 'Drain and disconnect from the hub, keeping the exposure warm'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "resume" -d 'Reconnect a paused exposure to the hub'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "stop" -d 'Stop exposing the workspace (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "restart" -d 'Restart the exposure (stop, then start with the given options)'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "status" -d 'Show the current workspace-exposure status'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "list" -d 'Show the current workspace-exposure status'
complete -c grok -n "__fish_grok_using_subcommand workspace; and not __fish_seen_subcommand_from start pause resume stop restart status list help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l hub-url -d 'Computer Hub WebSocket URL (default: `[hub].url`, then the prod hub)' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l cwd -d 'Workspace root directory to expose. Defaults to the current directory' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l leader -d 'Force leader mode for this command, overriding config'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l no-leader -d 'Refuse to start even when config enables leader mode'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from start" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from pause" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from resume" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from stop" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l hub-url -d 'Computer Hub WebSocket URL (default: `[hub].url`, then the prod hub)' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l cwd -d 'Workspace root directory to expose. Defaults to the current directory' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l leader -d 'Force leader mode for this command, overriding config'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l no-leader -d 'Refuse to start even when config enables leader mode'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from restart" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from status" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "start" -d 'Start (or update) the workspace-to-hub exposure'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "pause" -d 'Drain and disconnect from the hub, keeping the exposure warm'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "resume" -d 'Reconnect a paused exposure to the hub'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "stop" -d 'Stop exposing the workspace (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "restart" -d 'Restart the exposure (stop, then start with the given options)'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "status" -d 'Show the current workspace-exposure status'
complete -c grok -n "__fish_grok_using_subcommand workspace; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -s h -l help -d 'Print help (see more with \'grok help cursor-worker\')'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -f -a "start" -d 'Register the leader as a Cursor private worker (or restart it with new options)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -f -a "list" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and not __fish_seen_subcommand_from start stop status list help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l name -d 'Worker display name shown in Cursor (default: `[cursor_worker].name`, then the hostname)' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents; repeatable, the first one is the registered working directory. Defaults to `[cursor_worker].worker_dirs`' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l max-agents -d 'Maximum concurrent Cloud Agent claims (default: `[cursor_worker].max_agents`; unset means no cap)' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l timeout -d 'Seconds to wait for the registration before printing the status; `0` returns as soon as the leader accepted the start' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l leader -d 'Force leader mode for this command, overriding config'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l no-leader -d 'Refuse to start even when config enables leader mode'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from start" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from stop" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from status" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from help" -f -a "start" -d 'Register the leader as a Cursor private worker (or restart it with new options)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from help" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from help" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand cursor-worker; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -s h -l help -d 'Print help (see more with \'grok help worker\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "start" -d 'Run a leader in this terminal until Ctrl+C'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "list" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "controller" -d 'Claim pending Cloud Agent requests for team pools and run a spawn hook for each'
complete -c grok -n "__fish_grok_using_subcommand worker; and not __fish_seen_subcommand_from start stop status list controller help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from start" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from stop" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from status" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l pid -d 'Leader process ID from `grok leader list`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l pool -d 'Join a team Self-Hosted Pool' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l json -d 'Emit machine-readable JSON output'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from list" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l spawn -d 'Hook to run once per claimed request or missing warm worker' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l pool -d 'Pool to watch, or to keep warm with `--warm-idle`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l repository -d 'Only take requests for this repository URL. Required for repository-scoped keys' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l identity-audience -d 'Ask each claim for a signed identity token bound to this audience' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l warm-idle -d 'Keep this many idle workers connected in each `--pool`, without claiming' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l endpoint -d 'Cursor public API base for the claim calls and the hook\'s `CURSOR_API_URL`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l name -d 'Worker display name shown in Cursor' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l worker-dir -d 'Repository directory offered to Cursor Cloud Agents' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l max-agents -d 'Maximum concurrent Cloud Agent claims' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l pool-name -d 'Deprecated alias for `--pool <NAME>`. Needs `--pool` or `--single-use`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l label -d 'Routing label for the worker, as `key=value`. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l labels-file -d 'JSON or TOML file of worker labels. Cannot be combined with `--label`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l api-key -d 'Cursor API key the worker registers with, in place of your linked Cursor account' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l auth-token-file -d 'File holding the worker\'s Cursor auth token, re-read before every reconnect' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l worker-id -d 'Worker id a pool supervisor claimed a request for, in place of the saved id. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l on-session-start -d 'Command run on this host once a pool claim lands. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l on-session-end -d 'Command run on this host once a pool claim is released. Needs `--pool`' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l management-addr -d 'Serve worker health over HTTP for Kubernetes probes' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l mcp-tool-timeout -d 'How long a tool call to a stdio MCP server this worker runs may take. Repeatable' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l idle-release-timeout -d 'Seconds a claim may sit idle before Cursor releases it. 0 turns this off' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l data-dir -d 'Directory for this worker\'s state, served by its own leader' -r -f -a "(__fish_complete_directories)"
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l wait -d 'Wait for the leader already running on the worker\'s socket to stop, then start' -r
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l all-pools -d 'Watch every pool of the team, without registering any'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l session-token -d 'Give the hook a token that serves only its claim, in place of the API key'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l single-use -d 'Same as `--pool` (legacy alias)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l mint-github-token -d 'Let Cursor send the pool worker short-lived GitHub tokens during a claimed run'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l sync-dashboard-secrets -d 'Let Cursor send the pool worker the team\'s dashboard secrets as env variables'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l clone-git-repos -d 'Clone the claimed run\'s repository with the minted token'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l identity-socket -d 'Give each Cloud Agent its own OIDC identity socket'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l run-mcp-servers -d 'Run each Cloud Agent\'s stdio MCP servers on this pool worker'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from controller" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from help" -f -a "start" -d 'Run a leader in this terminal until Ctrl+C'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from help" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from help" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from help" -f -a "controller" -d 'Claim pending Cloud Agent requests for team pools and run a spawn hook for each'
complete -c grok -n "__fish_grok_using_subcommand worker; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand dashboard" -l leader-socket -d 'Use a custom leader socket path instead of the default `~/.grok/leader.sock`' -r -F
complete -c grok -n "__fish_grok_using_subcommand dashboard" -l debug-file -d 'Write debug logs to FILE' -r -F
complete -c grok -n "__fish_grok_using_subcommand dashboard" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c grok -n "__fish_grok_using_subcommand dashboard" -l debug -d 'Enable debug logging'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "agent" -d 'Run Grok without the interactive UI'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "inspect" -d 'Show the configuration Grok discovers for this directory'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "doctor" -d 'Check terminal, clipboard, color, and input support without starting Grok'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "leader" -d 'Manage running leader processes'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "logout" -d 'Sign out and clear cached credentials'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "login" -d 'Sign in to Grok'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "mcp" -d 'Manage MCP server configurations'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "plugin" -d 'Manage plugins and marketplace sources'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "memory" -d 'Manage cross-session memory'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "models" -d 'List available models and exit'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "sessions" -d 'List, search, or restore sessions'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "usage" -d 'Print your plan\'s usage limit, or a session\'s persisted token and cost usage'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "setup" -d 'Fetch and install managed configuration'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "wrap" -d 'Run any command with local clipboard support'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "export" -d 'Export a session transcript as Markdown'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "trace" -d 'Export or upload session trace data'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "update" -d 'Check for updates or install a specific version'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "version" -d 'Print version information'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "completions" -d 'Generate shell completion scripts (bash, zsh, fish, powershell, ...)'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "worktree" -d 'Manage git worktrees'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "clone" -d 'Lazy-clone a git repository via grove (NFS on macOS, FUSE on Linux)'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "du" -d 'Show what the grok home (~/.grok) uses on disk'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "workspace" -d 'Expose this workspace to the Computer Hub (via the leader)'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "cursor-worker" -d 'Register this machine as a Cursor private worker (via the leader)'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "worker" -d 'Run this machine as a Cursor private worker'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "dashboard" -d 'Open the Agent Dashboard view at startup'
complete -c grok -n "__fish_grok_using_subcommand help; and not __fish_seen_subcommand_from agent inspect doctor leader logout login mcp plugin memory models sessions usage setup wrap export trace update version completions worktree clone du workspace cursor-worker worker dashboard help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from agent" -f -a "stdio" -d 'Run the agent over stdio'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from agent" -f -a "headless" -d 'Run the agent headlessly over the Grok WebSocket relay'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from agent" -f -a "serve" -d 'Run the agent as a WebSocket server'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from agent" -f -a "leader" -d 'Run as the shared leader process for other clients'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from doctor" -f -a "fix" -d 'Apply an automatic fix'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from leader" -f -a "list" -d 'List running leader processes'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from leader" -f -a "info" -d 'Show details for a leader process'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from leader" -f -a "kill" -d 'Stop all running leader processes'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from leader" -f -a "worker" -d 'Run the same commands as `grok worker`'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "list" -d 'List configured MCP servers'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "add" -d 'Add or update an MCP server'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "remove" -d 'Remove an MCP server'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "enable" -d 'Enable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "disable" -d 'Disable an MCP server'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from mcp" -f -a "doctor" -d 'Diagnose MCP server configuration and connectivity'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "list" -d 'List installed plugins'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "install" -d 'Install a plugin from a git URL or local path'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "uninstall" -d 'Uninstall an installed plugin by name'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "update" -d 'Update installed plugin(s)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "enable" -d 'Enable a disabled plugin'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "disable" -d 'Disable a plugin without uninstalling it'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "details" -d 'Show a plugin\'s component inventory'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "validate" -d 'Validate a plugin manifest'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "tag" -d 'Create a release git tag from the plugin\'s manifest version'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from plugin" -f -a "marketplace" -d 'Manage marketplace sources'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from memory" -f -a "clear" -d 'Clear memory files (workspace by default)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from memory" -f -a "serve" -d 'Serve memory to this user\'s grok processes over a local socket until idle'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from sessions" -f -a "list" -d 'List recent sessions (same as search with no query)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from sessions" -f -a "search" -d 'Search sessions by keyword'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from sessions" -f -a "delete" -d 'Permanently delete a session from history'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "create" -d 'Create a worktree the way `grok -w` does, without starting a session'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "list" -d 'List the registry\'s worktrees, unfinished copies and Grove clones'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "show" -d 'Show details for a specific worktree'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "rm" -d 'Remove worktrees, or Grove clones through the daemon that owns them'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "gc" -d 'Remove expired worktrees, keeping any whose work would not survive'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "detach" -d 'Convert a Grove-projected worktree into a plain git worktree'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "salvage" -d 'Recover a Grove worktree\'s hydrated and dirty files when its source repo is gone'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "clean-artifacts" -d 'Purge escape-dir artifact contents (`git clean` does not)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "redirect" -d 'Inspect and repair artifact-directory redirections'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worktree" -f -a "db" -d 'Database maintenance'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "start" -d 'Start (or update) the workspace-to-hub exposure'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "pause" -d 'Drain and disconnect from the hub, keeping the exposure warm'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "resume" -d 'Reconnect a paused exposure to the hub'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "stop" -d 'Stop exposing the workspace (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "restart" -d 'Restart the exposure (stop, then start with the given options)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from workspace" -f -a "status" -d 'Show the current workspace-exposure status'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from cursor-worker" -f -a "start" -d 'Register the leader as a Cursor private worker (or restart it with new options)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from cursor-worker" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from cursor-worker" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worker" -f -a "start" -d 'Run a leader in this terminal until Ctrl+C'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worker" -f -a "stop" -d 'Unregister from Cursor and release the claims (the leader keeps running)'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worker" -f -a "status" -d 'Show the current worker status and its Cloud Agent claims'
complete -c grok -n "__fish_grok_using_subcommand help; and __fish_seen_subcommand_from worker" -f -a "controller" -d 'Claim pending Cloud Agent requests for team pools and run a spawn hook for each'
