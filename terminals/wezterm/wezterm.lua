-- WezTerm
-- https://wezfurlong.org/wezterm/
local wezterm = require("wezterm")
local theme = require("theme")
local fonts = require("fonts")
-- local keys = require("keys")
-- local tabs = require("tabs")

-- tabs.setup()
local gpus = wezterm.gui.enumerate_gpus()

local config = {
	enable_wayland = true,
	pane_focus_follows_mouse = false,
	warn_about_missing_glyphs = false,
	check_for_updates = false,
	window_decorations = "NONE|RESIZE|MACOS_FORCE_DISABLE_SHADOW",
	window_close_confirmation = "NeverPrompt",
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
	hide_tab_bar_if_only_one_tab = true,
	enable_scroll_bar = false,
	webgpu_preferred_adapter = gpus[1],
	front_end = "WebGpu",
}

fonts.setup(config)
theme.setup(config)
-- keys.setup(config)

return config
