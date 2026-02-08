-- Tabs module - status bar and tab formatting (like tmux status line)
local wezterm = require("wezterm")

local Tabs = {}

-- Colors for status bar (matching your theme)
local colors = {
	bg = "#1C1C20",
	fg = "#d3c6aa",
	active_bg = "#374145",
	active_fg = "#e0d7c3",
	workspace_bg = "#59a6c3",
	workspace_fg = "#0F0F0F",
	zoomed_bg = "#e06062",
	leader_bg = "#b0cc76",
}

-- Get folder name from path
local function basename(path)
	if not path then
		return ""
	end
	return path:match("([^/]+)$") or path
end

-- Format tab title
local function tab_title(tab_info, max_width)
	local tab_index = tab_info.tab_index
	local title = tab_info.tab_title

	-- Use custom title if set, otherwise use pane title or cwd
	if title and #title > 0 then
		-- Custom title set
	else
		local pane = tab_info.active_pane
		local cwd = pane.current_working_dir
		if cwd then
			-- Extract folder name from URL
			local path = cwd.file_path or cwd:gsub("file://[^/]*", "")
			title = basename(path)
		else
			title = pane.title
		end
	end

	-- Truncate if needed
	title = wezterm.truncate_right(title, max_width - 4)
	return string.format(" %d: %s ", tab_index + 1, title)
end

function Tabs.setup(config)
	-- Tab bar colors
	config.colors = config.colors or {}
	config.colors.tab_bar = {
		background = colors.bg,
		active_tab = {
			bg_color = colors.active_bg,
			fg_color = colors.active_fg,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = colors.bg,
			fg_color = colors.fg,
		},
		inactive_tab_hover = {
			bg_color = colors.active_bg,
			fg_color = colors.active_fg,
		},
		new_tab = {
			bg_color = colors.bg,
			fg_color = colors.fg,
		},
		new_tab_hover = {
			bg_color = colors.active_bg,
			fg_color = colors.active_fg,
		},
	}

	-- Format tab titles
	wezterm.on("format-tab-title", function(tab, tabs, panes, _config, hover, max_width)
		local title = tab_title(tab, max_width)

		local bg = tab.is_active and colors.active_bg or colors.bg
		local fg = tab.is_active and colors.active_fg or colors.fg

		-- Add zoom indicator
		if tab.active_pane.is_zoomed then
			title = " " .. title
		end

		return {
			{ Background = { Color = bg } },
			{ Foreground = { Color = fg } },
			{ Text = title },
		}
	end)

	-- Update right status (workspace name, time, etc. - like tmux status-right)
	wezterm.on("update-right-status", function(window, pane)
		local workspace = window:active_workspace()
		local date = wezterm.strftime("%H:%M")

		-- Check if leader key is active
		local leader = ""
		if window:leader_is_active() then
			leader = " LEADER "
		end

		-- Check if pane is zoomed
		local zoom = ""
		if pane:tab():active_pane():is_zoomed() then
			zoom = " ZOOM "
		end

		-- Build status elements
		local elements = {}

		-- Leader indicator
		if leader ~= "" then
			table.insert(elements, { Background = { Color = colors.leader_bg } })
			table.insert(elements, { Foreground = { Color = colors.workspace_fg } })
			table.insert(elements, { Text = leader })
		end

		-- Zoom indicator
		if zoom ~= "" then
			table.insert(elements, { Background = { Color = colors.zoomed_bg } })
			table.insert(elements, { Foreground = { Color = colors.workspace_fg } })
			table.insert(elements, { Text = zoom })
		end

		-- Time
		table.insert(elements, { Background = { Color = colors.bg } })
		table.insert(elements, { Foreground = { Color = colors.fg } })
		table.insert(elements, { Text = " " .. date .. " " })

		window:set_right_status(wezterm.format(elements))
	end)

	-- Update left status - show workspace name with icon
	wezterm.on("update-status", function(window, pane)
		local workspace = window:active_workspace()
		local icon = ""

		local elements = {
			{ Background = { Color = colors.bg } },
			{ Foreground = { Color = colors.workspace_bg } },
			{ Text = " " .. icon .. "  " .. workspace .. " " },
		}

		window:set_left_status(wezterm.format(elements))
	end)
end

return Tabs
