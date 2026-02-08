-- Keys module - tmux-like keybindings for WezTerm
local wezterm = require("wezterm")
local workspaces = require("workspaces")
local act = wezterm.action

local Keys = {}

local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }

-- Helper for pane navigation/resize
local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "LEADER|SHIFT" or "LEADER",
		action = wezterm.action_callback(function(win, pane)
			if resize_or_move == "resize" then
				win:perform_action({ AdjustPaneSize = { direction_keys[key], 5 } }, pane)
			else
				win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

function Keys.setup(config)
	-- Leader key: Ctrl-a (same as your tmux)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	config.keys = {
		-- ==========================================
		-- Workspace/Session Management (like tmux sessions)
		-- ==========================================
		-- Switch workspace with fuzzy finder (like tmux: prefix + s)
		{ key = "s", mods = "LEADER", action = workspaces.switch_workspace() },
		-- List active workspaces only
		{ key = "w", mods = "LEADER", action = workspaces.list_workspaces() },
		-- Create new workspace (like tmux: prefix + C-c)
		{ key = "c", mods = "LEADER|CTRL", action = workspaces.new_workspace() },
		-- Rename workspace
		{ key = "$", mods = "LEADER|SHIFT", action = workspaces.rename_workspace() },
		-- Switch to last tab (like tmux: prefix + Tab)
		{ key = "Tab", mods = "LEADER", action = act.ActivateLastTab },
		-- Open project as pane (explicit - always splits right)
		{ key = "o", mods = "LEADER", action = workspaces.open_as_pane() },
		-- Open project as pane below
		{ key = "O", mods = "LEADER|SHIFT", action = workspaces.open_as_pane_down() },

		-- Toggle last workspace (like tmux: prefix + \)
		{ key = "\\", mods = "LEADER", action = workspaces.switch_to_last() },

		-- ==========================================
		-- Pane Management
		-- ==========================================
		-- Split pane vertically (like tmux: prefix + |)
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = act.SplitPane({ direction = "Right", size = { Percent = 30 } }),
		},
		-- Split pane horizontally (like tmux: prefix + -)
		{
			key = "-",
			mods = "LEADER",
			action = act.SplitPane({ direction = "Down", size = { Percent = 30 } }),
		},
		-- Close pane
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
		-- Zoom pane toggle (like tmux: prefix + z)
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

		-- Tab navigation (prefix + h/l or Ctrl+Shift+h/l for fast switching)
		{ key = "h", mods = "LEADER", action = act.ActivateTabRelative(-1) },
		{ key = "l", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },

		-- Pane navigation (prefix + j/k for up/down panes)
		split_nav("move", "j"),
		split_nav("move", "k"),

		-- Pane resize (like tmux: prefix + H/J/K/L)
		split_nav("resize", "h"),
		split_nav("resize", "j"),
		split_nav("resize", "k"),
		split_nav("resize", "l"),

		-- ==========================================
		-- Tab/Window Management
		-- ==========================================
		-- New tab (like tmux: prefix + c for new window)
		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		-- Close tab
		{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
		-- Next/Previous tab (like tmux: prefix + n/p or C-l/C-h)
		{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
		{ key = "l", mods = "LEADER|CTRL", action = act.ActivateTabRelative(1) },
		{ key = "h", mods = "LEADER|CTRL", action = act.ActivateTabRelative(-1) },
		-- Rename tab
		{
			key = ",",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Rename tab:",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		-- Move tabs (like tmux: prefix + < / >)
		{ key = "<", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
		{ key = ">", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

		-- Tab by number
		{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
		{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
		{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
		{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
		{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
		{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
		{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
		{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
		{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },

		-- ==========================================
		-- Quick Launch (like tmux temporary windows)
		-- ==========================================
		-- Quick launcher menu
		{ key = "a", mods = "LEADER", action = workspaces.quick_launcher() },
		-- LazyGit (like tmux: prefix + g)
		{
			key = "g",
			mods = "LEADER",
			action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL"), "-l", "-c", "lazygit" } }),
		},
		-- LazyDocker (like tmux: prefix + i)
		{
			key = "i",
			mods = "LEADER",
			action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL"), "-l", "-c", "lazydocker" } }),
		},
		-- SuperFile (like tmux: prefix + /)
		{
			key = "/",
			mods = "LEADER",
			action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL"), "-l", "-c", "spf" } }),
		},

		-- ==========================================
		-- Copy Mode (like tmux: prefix + v or prefix + [)
		-- ==========================================
		{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },
		{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },

		-- ==========================================
		-- Search (like tmux: prefix + f)
		-- ==========================================
		{ key = "f", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },

		-- ==========================================
		-- Misc
		-- ==========================================
		-- Reload config (like tmux: prefix + r)
		{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
		-- Show debug overlay (like tmux: prefix + D)
		{ key = "d", mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },
		-- Command palette
		{ key = ":", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
		-- Toggle fullscreen
		{ key = "Enter", mods = "CMD", action = act.ToggleFullScreen },

		-- ==========================================
		-- Font size
		-- ==========================================
		{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
		{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
		{ key = "0", mods = "CMD", action = act.ResetFontSize },

		-- ==========================================
		-- Clipboard
		-- ==========================================
		{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
		{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

		-- ==========================================
		-- Quick tab access with CMD
		-- ==========================================
		{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
		{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
		{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
		{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
		{ key = "5", mods = "CMD", action = act.ActivateTab(4) },
		{ key = "6", mods = "CMD", action = act.ActivateTab(5) },
		{ key = "7", mods = "CMD", action = act.ActivateTab(6) },
		{ key = "8", mods = "CMD", action = act.ActivateTab(7) },
		{ key = "9", mods = "CMD", action = act.ActivateTab(8) },
		{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
		{ key = "[", mods = "CMD", action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = "CMD", action = act.ActivateTabRelative(1) },

		-- Send Ctrl-L (clear screen) - since C-l is used for pane nav
		{ key = "l", mods = "CTRL", action = act.SendKey({ key = "l", mods = "CTRL" }) },
	}

	-- Copy mode key bindings (vim-style)
	config.key_tables = {
		copy_mode = {
			{ key = "Escape", action = act.CopyMode("Close") },
			{ key = "q", action = act.CopyMode("Close") },
			{ key = "h", action = act.CopyMode("MoveLeft") },
			{ key = "j", action = act.CopyMode("MoveDown") },
			{ key = "k", action = act.CopyMode("MoveUp") },
			{ key = "l", action = act.CopyMode("MoveRight") },
			{ key = "w", action = act.CopyMode("MoveForwardWord") },
			{ key = "b", action = act.CopyMode("MoveBackwardWord") },
			{ key = "e", action = act.CopyMode("MoveForwardWordEnd") },
			{ key = "0", action = act.CopyMode("MoveToStartOfLine") },
			{ key = "$", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "^", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "g", action = act.CopyMode("MoveToScrollbackTop") },
			{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
			{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "v", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
			{
				key = "y",
				action = act.Multiple({
					act.CopyTo("ClipboardAndPrimarySelection"),
					act.CopyMode("Close"),
				}),
			},
			{ key = "/", action = act.Search({ CaseInSensitiveString = "" }) },
			{ key = "n", action = act.CopyMode("NextMatch") },
			{ key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
			{ key = "PageUp", action = act.CopyMode("PageUp") },
			{ key = "PageDown", action = act.CopyMode("PageDown") },
			{ key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },
			{ key = "d", mods = "CTRL", action = act.CopyMode("PageDown") },
		},
		search_mode = {
			{ key = "Escape", action = act.CopyMode("Close") },
			{ key = "Enter", action = act.CopyMode("AcceptPattern") },
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		},
	}
end

return Keys
