local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == "base" then
  vim.cmd [[
    set background=dark

    colorscheme base-jabuti

    hi Normal guibg=#262221
  ]]

  transaprent()

  local colors = {}

  colors.input = "#211D1C"
  colors.result = "#211D1C"
  colors.counter = "#739B79"
  colors.selection_bg = "#383635"
  colors.title = "#739B79"
  colors.title_bg = "#2E2C2F"

  highlight_telescope(colors)
end

if vim.g.theme == "frappe" then
  vim.cmd [[
    set background=dark
    colorscheme base-catppuccin-frappe
  ]]

  transaprent()

  local colors = {}

  colors.input = "#2C2E3C"
  colors.result = "#2C2E3C"
  colors.counter = "#CA9EE6"
  colors.selection_bg = "#414660"

  highlight_telescope(colors)
end

if vim.g.theme == 'latte' then
  vim.cmd [[
    set background=light
    colorscheme base-penumbra-light
  ]]

  transaprent()

  local colors = {}

  colors.input = "#E7EBF1"
  colors.selection_bg = "#BCC0CB"
  colors.result = "#E7EBF1"
  colors.counter = "#7287FE"


  highlight_telescope(colors)
end
