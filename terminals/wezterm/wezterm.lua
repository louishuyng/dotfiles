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

local gpus = wezterm.gui.enumerate_gpus()

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

-- ==========================================
-- Window Settings
-- ==========================================
config.window_decorations = "NONE|RESIZE|MACOS_FORCE_DISABLE_SHADOW"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_cols = 140
config.initial_rows = 40
config.enable_scroll_bar = false

-- ==========================================
-- GPU/Rendering
-- ==========================================
if gpus[1] then
	config.webgpu_preferred_adapter = gpus[1]
	config.front_end = "WebGpu"
end

-- ==========================================
-- Tab Bar Settings
-- ==========================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false -- Always show to display workspace
config.tab_max_width = 32
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false

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
tabs.setup(config)

return config
