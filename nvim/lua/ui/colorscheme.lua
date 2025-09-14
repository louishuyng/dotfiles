local highlight_utils = require 'ui.highlight_utils'

local highlight_telescope = highlight_utils.highlight_telescope
local palettes = require('catppuccin.palettes')

if vim.g.theme == 'night' then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin
  ]]
end

if vim.g.theme == 'light' then
  vim.cmd [[
    set background=light
    colorscheme catppuccin
  ]]
end

local C = palettes.get_palette(vim.g.default_dark_catppuccin_theme)
local colors = {}

colors.input = C.mantle
colors.result = C.mantle
colors.counter = C.green
colors.selection_bg = C.base
colors.title = C.yellow
colors.title_bg = C.crust

highlight_telescope(colors)
