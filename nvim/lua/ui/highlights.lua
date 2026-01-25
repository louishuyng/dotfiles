local highlight_utils = require 'ui.highlight_utils'

local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == 'night' then
  vim.cmd [[
    set background=dark
    colorscheme midnight
  ]]
end

if vim.g.theme == 'light' then
  vim.cmd [[
    set background=light
    colorscheme daylight
  ]]
end

-- Function to get colors based on current theme
local function get_theme_colors()
  if vim.g.theme == 'light' then
    return require('lush_themes.daylight.colors')
  else
    return require('lush_themes.midnight.colors')
  end
end

local theme_colors = get_theme_colors()

local colors = {}

colors.input = theme_colors.bg_dark
colors.result = theme_colors.bg_dark
colors.counter = theme_colors.green
colors.selection_bg = theme_colors.bg
colors.title = theme_colors.yellow
colors.title_bg = theme_colors.bg_float

highlight_telescope(colors)
