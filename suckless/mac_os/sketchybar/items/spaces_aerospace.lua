-- Aerospace backend for spaces.lua.
--
-- IDs are aerospace workspace names (e.g. "1", "2", "code").
-- fetch_state_cmd emits two sections separated by "---":
--   1. one "workspace_id|app_name" line per window
--   2. the focused workspace id on its own line

local M = {}

M.events = { "aerospace_workspace_change", "front_app_switched" }

-- The aerospace CLI can block forever on its server socket. Sketchybar never
-- reaps the stuck child, so an unguarded call leaks an sh+aerospace pair on
-- every poll — ~2/day until the machine is rebooted.
local ae = "timeout 3 aerospace"

function M.list_workspaces_cmd()
	return ae .. " list-workspaces --all"
end

function M.fetch_state_cmd()
	return ae
		.. " list-windows --all --format '%{workspace}|%{app-name}' && echo '---' && "
		.. ae
		.. " list-workspaces --focused"
end

function M.click_cmd(workspace_id)
	return ae .. ' workspace "' .. workspace_id .. '"'
end

-- Pill label for the focused workspace. Aerospace workspace IDs are already
-- the user-facing names ("1", "2", "code"), so show them as-is.
function M.display_label(workspace_id)
	return workspace_id
end

-- Pill display order, most-used first. Aerospace's list-workspaces returns
-- alphabetical order, which buries the workspaces used most. Workspaces absent
-- from this list still get a pill — they sort alphabetically after the listed
-- ones — so adding a workspace in aerospace.toml never makes it invisible here.
M.display_order = {
	"Tool",
	"Code",
	"Web",
	"Chat",
	"Reading",
	"Planing",
	"Any",
	"Inbox",
	"Virtual",
}

return M
