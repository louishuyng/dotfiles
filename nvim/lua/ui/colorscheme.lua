local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope
local diagnosticTransparent = highlight_utils.diagnosticTransparent

if vim.g.theme == 'night' then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin
  ]]

  transaprent()
end

if vim.g.theme == 'light' then
  vim.cmd [[
    set background=light
    colorscheme catppuccin
  ]]

  transaprent()
  gitTransparent()
end

local flavour = vim.g.theme == 'night' and vim.g.default_dark_catppuccin_theme or 'latte'

local C = require('catppuccin.palettes').get_palette(flavour)

local colors = {}

colors.input = C.mantle
colors.result = C.mantle
colors.counter = C.green
colors.selection_bg = C.base
colors.title = C.yellow
colors.title_bg = C.crust

highlight_telescope(colors)
