-- WezTerm Configuration
-- https://wezfurlong.org/wezterm/
--
-- A tmux replacement with built-in multiplexing
-- See README.md for usage instructions

local wezterm = require("wezterm")
local theme = require("theme")
local fonts = require("fonts")
local keys = require("keys")
local tabs = require("tabs")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- ==========================================
-- Default Directory & Workspace
-- ==========================================
config.default_cwd = wezterm.home_dir .. "/.dotfiles"
config.default_workspace = "HOME"

-- ==========================================
-- General Settings
-- ==========================================
config.enable_wayland = true
config.pane_focus_follows_mouse = false
config.warn_about_missing_glyphs = false
config.check_for_updates = false
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.status_update_interval = 100

-- ==========================================
-- Window Settings
-- ==========================================
config.window_decorations = "NONE|RESIZE|MACOS_FORCE_DISABLE_SHADOW"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_cols = 140
config.initial_rows = 40
config.enable_scroll_bar = false
config.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }

-- ==========================================
-- GPU/Rendering
-- ==========================================
config.front_end = "OpenGL"
config.max_fps = 120

-- ==========================================
-- Tab Bar Settings
-- ==========================================
tabs.setup(config, tabline)

-- ==========================================
-- Scrollback
-- ==========================================
config.scrollback_lines = 10000

-- ==========================================
-- Cursor
-- ==========================================
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ==========================================
-- Bell
-- ==========================================
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- ==========================================
-- Hyperlinks
-- ==========================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ==========================================
-- Apply Modules
-- ==========================================
fonts.setup(config)
theme.setup(config)
keys.setup(config)

-- File-based IPC for workspace switching from Raycast
config.status_update_interval = 100

local IPC_FILE = os.getenv("HOME") .. "/.wezterm-workspace-switch"

wezterm.on("update-status", function(window, pane)
	local f = io.open(IPC_FILE, "r")
	if not f then
		return
	end

	local workspace_name = f:read("*line")
	f:close()

	if workspace_name and workspace_name ~= "" then
		-- Switch to the requested workspace
		window:perform_action(wezterm.action.SwitchToWorkspace({ name = workspace_name }), pane)
		-- Clean up the IPC file
		os.remove(IPC_FILE)
	end
end)

return config
