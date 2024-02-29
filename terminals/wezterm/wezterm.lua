-- WezTerm
-- https://wezfurlong.org/wezterm/
local wezterm = require 'wezterm'
local theme = require("theme")
local fonts = require("fonts")
local keys = require("keys")
local tabs = require("tabs")

tabs.setup()

local gpus = wezterm.gui.enumerate_gpus()

local config = {
  enable_wayland = false,
  pane_focus_follows_mouse = false,
  warn_about_missing_glyphs = false,
  use_fancy_tab_bar = false,
  tab_max_width = 50,
  show_update_window = false,
  check_for_updates = false,
  window_decorations = "NONE | RESIZE",
  window_close_confirmation = "NeverPrompt",
  inactive_pane_hsb = {
    saturation = 1.0,
    brightness = wezterm.GLOBAL.is_dark and 0.90 or 0.95
  },
  window_padding = {left = 0, right = 0, top = 0, bottom = 0},
  enable_scroll_bar = false,
  window_background_opacity = 1.0,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance"
}

fonts.setup(config)
theme.setup(config)
keys.setup(config)

return config
