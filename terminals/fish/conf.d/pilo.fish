set -l pilo_usage "$HOME/.pilo/mods/pilo-usage"
if test -f "$pilo_usage/.claude-plugin/plugin.json"
    set -gx --path CLAUDE_CODE_PLUGIN_DIRS $CLAUDE_CODE_PLUGIN_DIRS
    if not contains -- "$pilo_usage" $CLAUDE_CODE_PLUGIN_DIRS
        set -gx --path CLAUDE_CODE_PLUGIN_DIRS $CLAUDE_CODE_PLUGIN_DIRS "$pilo_usage"
    end
end
