local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope

if vim.g.theme == "base" then
  vim.cmd [[
    set background=dark

    colorscheme base-jabuti

    hi Normal guibg=#262221
    hi MiniStatuslineModeNormal guifg=#BE95FF guibg=NONE
    hi MiniStatuslineModeInsert guifg=#FFA07A guibg=NONE
    hi MiniStatuslineModeVisual guifg=#98C379 guibg=NONE
    hi MiniStatuslineModeReplace guifg=#FF6C6B guibg=NONE
    hi MiniStatuslineModeCommand guifg=#61AFEF guibg=NONE
    hi MiniStatuslineModeOther guifg=#61AFEF guibg=NONE
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
  transaprent()
end

if vim.g.theme == "frappe" then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin
  ]]

  transaprent()

  local colors = {}

  colors.input = "#191B1C"
  colors.result = "#191B1C"
  colors.counter = "#89B482"
  colors.selection_bg = "#252626"

  highlight_telescope(colors)
end

if vim.g.theme == "solarized" then
  vim.cmd [[
    set background=dark
    colorscheme base-solarized-osaka
  ]]

  transaprent()

  local colors = {}

  colors.input = "#02202D"
  colors.result = "#02202D"
  colors.counter = "#29A298"
  colors.selection_bg = "#0D3B4A"

  highlight_telescope(colors)
end

if vim.g.theme == 'latte' then
  vim.cmd [[
    set background=light
    colorscheme base-flexoki-light
  ]]

  transaprent()

  local colors = {}

  colors.input = "#F6EDE3"
  colors.selection_bg = "#BCC0CB"
  colors.result = "#F6EDE3"
  colors.counter = "#3EA57B"


  highlight_telescope(colors)
end
