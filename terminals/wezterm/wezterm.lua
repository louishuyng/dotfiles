-- WezTerm
-- https://wezfurlong.org/wezterm/
local wezterm = require 'wezterm'
local theme = require("theme")
local fonts = require("fonts")

local config = {
  enable_wayland = false,
  pane_focus_follows_mouse = false,
  warn_about_missing_glyphs = false,
  show_update_window = false,
  check_for_updates = false,
  window_decorations = "NONE | RESIZE",
  window_close_confirmation = "NeverPrompt",
  window_padding = {left = 0, right = 0, top = 0, bottom = 0},

  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = false,
  window_background_opacity = 1.0,

  -- Cursor style
  default_cursor_style = 'BlinkingBar',

  -- Adapter
  front_end = 'WebGpu'
}

fonts.setup(config)
theme.setup(config)

return config
