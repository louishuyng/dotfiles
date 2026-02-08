-- Workspaces module - tmux-like session management for WezTerm
-- Simple rule: Same parent folder = same workspace
local wezterm = require("wezterm")
local act = wezterm.action

local Workspaces = {}

-- Project directories to scan
Workspaces.project_dirs = {
	"~/LX14/repository/github.com/louishuyng",
	"~/LX14/repository/github.com/regask",
}

-- Predefined workspaces
Workspaces.predefined = {
	{
		name = "HOME",
		cwd = "~/.dotfiles",
	},
	{
		name = "LX14",
		cwd = "~/LX14/repository/github.com/louishuyng",
	},
	{
		name = "Regask",
		cwd = "~/LX14/repository/github.com/regask",
	},
}

-- Helper: Get parent directory
local function get_parent(path)
	if not path then
		return nil
	end
	return path:match("(.+)/[^/]+$")
end

-- Helper: Get folder name from path
local function get_name(path)
	if not path then
		return nil
	end
	return path:match("([^/]+)$")
end

-- Helper: Get pane's working directory
local function get_cwd(pane)
	local cwd = pane:get_current_working_dir()
	if cwd then
		if cwd.file_path then
			return cwd.file_path
		end
		local path = tostring(cwd)
		return path:gsub("file://[^/]*", "")
	end
	return nil
end

-- Helper: Get predefined workspace name for a parent directory
local function get_predefined_ws_name(parent_dir)
	for _, ws in ipairs(Workspaces.predefined) do
		local expanded = wezterm.home_dir .. ws.cwd:gsub("~", "")
		if expanded == parent_dir then
			return ws.name
		end
	end
	return nil
end

-- Get all projects from configured directories
local function get_projects()
	local projects = {}

	-- Add predefined
	for _, ws in ipairs(Workspaces.predefined) do
		local path = wezterm.home_dir .. ws.cwd:gsub("~", "")
		table.insert(projects, { path = path, name = ws.name, parent = get_parent(path) })
	end

	-- Scan directories
	for _, dir in ipairs(Workspaces.project_dirs) do
		local expanded = dir:gsub("~", wezterm.home_dir)
		local success, entries = pcall(wezterm.read_dir, expanded)
		if success and entries then
			for _, entry in ipairs(entries) do
				local name = get_name(entry)
				if name and not name:match("^%.") then
					table.insert(projects, { path = entry, name = name, parent = expanded })
				end
			end
		end
	end

	return projects
end

-- Find if a project is already open (exact path match)
local function find_open_project(project_path)
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		local ws_name = mux_win:get_workspace()
		for idx, tab in ipairs(mux_win:tabs()) do
			local tab_cwd = get_cwd(tab:active_pane())
			if tab_cwd == project_path then
				return { workspace = ws_name, tab_index = idx - 1 }
			end
		end
	end
	return nil
end

-- Find workspace that contains a tab with the same parent directory
local function find_workspace_by_parent(parent_dir)
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		for _, tab in ipairs(mux_win:tabs()) do
			local tab_cwd = get_cwd(tab:active_pane())
			if tab_cwd then
				local tab_parent = get_parent(tab_cwd)
				if tab_parent == parent_dir then
					return mux_win:get_workspace()
				end
			end
		end
	end
	return nil
end

-- Ctrl-a s: Search and switch to project
-- 1. If already open -> switch to that tab
-- 2. If same parent open -> add tab to that workspace
-- 3. Otherwise -> create new workspace
function Workspaces.switch_workspace()
	return wezterm.action_callback(function(window, pane)
		local projects = get_projects()
		local current_workspace = window:active_workspace()
		local choices = {}

		for _, proj in ipairs(projects) do
			table.insert(choices, { id = proj.path, label = proj.name })
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id then
						return
					end

					-- 1. Check if project is already open
					local existing = find_open_project(id)
					if existing then
						if existing.workspace == current_workspace then
							-- Same workspace: just activate tab
							inner_window:perform_action(act.ActivateTab(existing.tab_index), inner_pane)
						else
							-- Different workspace: switch and activate tab
							inner_window:perform_action(
								act.SwitchToWorkspace({ name = existing.workspace }),
								inner_pane
							)
							wezterm.time.call_after(0.1, function()
								local gui_win = wezterm.gui.gui_windows()[1]
								if gui_win then
									gui_win:perform_action(act.ActivateTab(existing.tab_index), gui_win:active_pane())
								end
							end)
						end
						return
					end

					-- 2. Check if same parent is already open somewhere
					local selected_parent = get_parent(id)
					local existing_workspace = find_workspace_by_parent(selected_parent)

					if existing_workspace then
						-- Switch to existing workspace and open as new tab
						inner_window:perform_action(act.SwitchToWorkspace({ name = existing_workspace }), inner_pane)
						wezterm.time.call_after(0.1, function()
							local gui_win = wezterm.gui.gui_windows()[1]
							if gui_win then
								gui_win:perform_action(act.SpawnCommandInNewTab({ cwd = id }), gui_win:active_pane())
							end
						end)
					else
						-- 3. Create new workspace - use predefined name or parent folder name
						local ws_name = get_predefined_ws_name(selected_parent) or get_name(selected_parent) or label
						inner_window:perform_action(
							act.SwitchToWorkspace({
								name = ws_name,
								spawn = { cwd = id },
							}),
							inner_pane
						)
					end
				end),
				title = "Projects",
				choices = choices,
				fuzzy = true,
				fuzzy_description = "Search > ",
			}),
			pane
		)
	end)
end

-- Ctrl-a w: List ALL open tabs across ALL workspaces
function Workspaces.list_workspaces()
	return wezterm.action_callback(function(window, pane)
		local current_workspace = window:active_workspace()
		local current_tab_id = pane:tab():tab_id()
		local choices = {}
		local tab_lookup = {}

		for _, mux_win in ipairs(wezterm.mux.all_windows()) do
			local ws_name = mux_win:get_workspace()
			local is_current = (ws_name == current_workspace)

			for idx, tab in ipairs(mux_win:tabs()) do
				local tab_id = tab:tab_id()
				if tab_id ~= current_tab_id then
					local tab_cwd = get_cwd(tab:active_pane())
					local tab_name = get_name(tab_cwd) or ("Tab " .. idx)
					local icon = is_current and "●" or "◆"
					local label = icon .. " " .. tab_name .. " [" .. ws_name .. "]"

					local choice_id = ws_name .. ":" .. tostring(tab_id) .. ":" .. tostring(idx - 1)
					table.insert(choices, { id = choice_id, label = label })
					tab_lookup[choice_id] = {
						workspace = ws_name,
						tab_index = idx - 1,
						is_current = is_current,
					}
				end
			end
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id then
						return
					end

					local info = tab_lookup[id]
					if not info then
						return
					end

					if info.is_current then
						inner_window:perform_action(act.ActivateTab(info.tab_index), inner_pane)
					else
						inner_window:perform_action(act.SwitchToWorkspace({ name = info.workspace }), inner_pane)
						wezterm.time.call_after(0.1, function()
							local gui_win = wezterm.gui.gui_windows()[1]
							if gui_win then
								gui_win:perform_action(act.ActivateTab(info.tab_index), gui_win:active_pane())
							end
						end)
					end
				end),
				title = "All Tabs",
				choices = choices,
				fuzzy = true,
				fuzzy_description = "Search tabs > ",
			}),
			pane
		)
	end)
end

-- Ctrl-a o: Open project as pane (split right)
function Workspaces.open_as_pane()
	return wezterm.action_callback(function(window, pane)
		local projects = get_projects()
		local choices = {}
		for _, proj in ipairs(projects) do
			table.insert(choices, { id = proj.path, label = proj.name })
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id then
						inner_window:perform_action(
							act.SplitPane({
								direction = "Right",
								size = { Percent = 50 },
								command = { cwd = id },
							}),
							inner_pane
						)
					end
				end),
				title = "Open as Pane",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

-- Ctrl-a O: Open project as pane (split down)
function Workspaces.open_as_pane_down()
	return wezterm.action_callback(function(window, pane)
		local projects = get_projects()
		local choices = {}
		for _, proj in ipairs(projects) do
			table.insert(choices, { id = proj.path, label = proj.name })
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id then
						inner_window:perform_action(
							act.SplitPane({
								direction = "Down",
								size = { Percent = 50 },
								command = { cwd = id },
							}),
							inner_pane
						)
					end
				end),
				title = "Open as Pane (Down)",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

-- Ctrl-a Ctrl-c: Create new workspace
function Workspaces.new_workspace()
	return wezterm.action_callback(function(window, pane)
		window:perform_action(
			act.PromptInputLine({
				description = "New workspace name:",
				action = wezterm.action_callback(function(inner_window, inner_pane, line)
					if line then
						inner_window:perform_action(act.SwitchToWorkspace({ name = line }), inner_pane)
					end
				end),
			}),
			pane
		)
	end)
end

-- Ctrl-a $: Rename current workspace
function Workspaces.rename_workspace()
	return wezterm.action_callback(function(window, pane)
		local current = window:active_workspace()
		window:perform_action(
			act.PromptInputLine({
				description = "Rename '" .. current .. "' to:",
				action = wezterm.action_callback(function(inner_window, inner_pane, line)
					if line then
						wezterm.mux.rename_workspace(current, line)
					end
				end),
			}),
			pane
		)
	end)
end

-- Ctrl-a Tab: Switch to last workspace
function Workspaces.switch_to_last()
	return act.SwitchWorkspaceRelative(-1)
end

-- Ctrl-a a: Quick launcher
function Workspaces.quick_launcher()
	return wezterm.action_callback(function(window, pane)
		local choices = {
			{ id = "lazygit", label = "LazyGit" },
			{ id = "lazydocker", label = "LazyDocker" },
			{ id = "htop", label = "Htop" },
			{ id = "spf", label = "SuperFile" },
			{ id = "yazi", label = "Yazi" },
			{ id = "nvim", label = "Neovim" },
		}
		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id then
						inner_window:perform_action(act.SpawnCommandInNewTab({ args = { id } }), inner_pane)
					end
				end),
				title = "Quick Launch",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

return Workspaces
