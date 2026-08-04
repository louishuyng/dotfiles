-- Aerospace backend for spaces.lua. Paired with spaces_omniwm.lua — both expose
-- the same module surface so spaces.lua can swap between them with one line.
--
-- IDs are aerospace workspace names (e.g. "1", "2", "code").
-- fetch_state_cmd emits two sections separated by "---":
--   1. one "workspace_id|app_name" line per window
--   2. the focused workspace id on its own line

local M = {}

M.events = { "aerospace_workspace_change", "front_app_switched" }

function M.list_workspaces_cmd()
	return "aerospace list-workspaces --all"
end

function M.fetch_state_cmd()
	return "aerospace list-windows --all --format '%{workspace}|%{app-name}' && echo '---' && aerospace list-workspaces --focused"
end

function M.click_cmd(workspace_id)
	return 'aerospace workspace "' .. workspace_id .. '"'
end

-- Pill label for the focused workspace. Aerospace workspace IDs are already
-- the user-facing names ("1", "2", "code"), so show them as-is.
function M.display_label(workspace_id)
	return workspace_id
end

return M
