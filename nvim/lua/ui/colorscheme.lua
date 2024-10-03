local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == "mocha" then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin

    hi Normal guibg=#0D1116
    hi NormalNC guibg=#0D1116
    hi WinSeparator guifg=#0D1116 guibg=NONE

    hi NvimTreeNormal guibg=#1A1C1E
  ]]

  transaprent()
  highlight_telescope()
end

if vim.g.theme == "solarized" then
  require("solarized-osaka").setup({
    transparent = false,
  })

  vim.cmd [[
    set background=dark
    colorscheme solarized-osaka

    hi Normal guibg=#01131A
    hi NormalNC guibg=#01131A
    hi WinSeparator guifg=#001419
    hi NvimTreeNormal guibg=#063643
    hi NvimTreeNormalNC guibg=#063643
  ]]

  local colors = {}
  colors.input = "#083642"
  colors.selection_bg = "#083642"
  colors.result = "#001217"
  colors.counter = "#859901"

  highlight_telescope(colors)
  transaprent()
end

if vim.g.theme == 'newpaper' then
  require("newpaper").setup({
    style = "dark",
  })

  vim.cmd [[
    colorscheme newpaper

    hi Normal guibg=#02040A
    hi NormalNC guibg=#02040A

    hi WinSeparator guifg=#02040A
    hi NvimTreeNormal guibg=#262626
    hi NvimTreeNormalNC guibg=#262626
  ]]

  local colors = {}

  colors.input = "#3B3B3B"
  colors.selection_bg = "#323232"
  colors.result = "#1e1e1e"
  colors.counter = "#C3E88D"

  highlight_telescope(colors)
  transaprent()
  gitTransparent()
end

if vim.g.theme == 'light' then
  require("cyberdream").setup({
    theme = {
      variant = "light",
    }
  })

  vim.cmd([[
    colorscheme cyberdream
  ]])
  transaprent()

  local colors = {}

  colors.input = "#F2D5CF"
  colors.selection_bg = "#ACACAC"
  colors.result = "#E4E4E4"
  colors.counter = "#0072C1"


  highlight_telescope(colors)
end

if vim.g.theme == 'cyberdream' then
  require("cyberdream").setup({
    theme = {
      variant = "dark",
    }
  })

  vim.cmd([[
    colorscheme cyberdream

    hi Normal guibg=#0F0F0F
    hi NormalNC guibg=#0F0F0F
    hi WinSeparator guifg=#0F0F0F guibg=NONE
    hi NvimTreeNormal guibg=#16181A
  ]])

  transaprent()

  local colors = {}

  colors.input = "#3C4048"
  colors.selection_bg = "#3C4048"
  colors.result = "#262626"
  colors.counter = "#5EFF6C"

  highlight_telescope(colors)
end
