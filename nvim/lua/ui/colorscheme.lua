local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local highlight_telescope = highlight_utils.highlight_telescope
local diagnosticTransparent = highlight_utils.diagnosticTransparent

if vim.g.theme == "base" then
  vim.cmd [[
    set background=dark

    colorscheme base-jabuti

    hi Normal guibg=#1A1A1A
    hi MiniStatuslineModeNormal guifg=#BE95FF guibg=NONE
    hi MiniStatuslineModeInsert guifg=#FFA07A guibg=NONE
    hi MiniStatuslineModeVisual guifg=#98C379 guibg=NONE
    hi MiniStatuslineModeReplace guifg=#FF6C6B guibg=NONE
    hi MiniStatuslineModeCommand guifg=#61AFEF guibg=NONE
    hi MiniStatuslineModeOther guifg=#61AFEF guibg=NONE
  ]]

  transaprent()

  local colors = {}

  colors.input = "#242137"
  colors.result = "#242137"
  colors.counter = "#739B79"
  colors.selection_bg = "#2E3338"
  colors.title = "#739B79"
  colors.title_bg = "#2E2C2F"

  highlight_telescope(colors)
  transaprent()
end

if vim.g.theme == "paper" then
  vim.cmd [[
    set background=dark
    colorscheme PaperColor

    hi Normal guibg=NONE
    hi CursorLineNr guibg=#303030
    hi NormalFloat guibg=NONE
    hi WinSeparator guifg=#606765 guibg=NONE
    hi Visual guibg=#8787AF guifg=#000009
    hi NonText guibg=NONE

    hi NamuPreview guibg=#303030 guifg=#ebdbb2
  ]]

  diagnosticTransparent()
  transaprent()

  local colors = {}

  colors.input = "#303030"
  colors.result = "#303030"
  colors.counter = "#739B79"
  colors.selection_bg = "#262626"
  colors.title = "#739B79"
  colors.title_bg = "#2E2C2F"

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
