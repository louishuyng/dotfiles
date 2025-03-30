local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope
local diagnosticTransparent = highlight_utils.diagnosticTransparent

local function defaultCursor()
  vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
end

if vim.g.theme == "night" then
  defaultCursor()

  vim.cmd [[
    set background=dark

    colorscheme catppuccin

    hi NvimTreeNormal guibg=NONE
    hi WinSeparator guifg=#C69FF5 guibg=NONE
  ]]

  transaprent()

  local colors = {}

  colors.input = "#1E2031"
  colors.result = "#1E2031"
  colors.counter = "#9D79D6"
  colors.selection_bg = "#313447"
  colors.title = "#8AADF3"
  colors.title_bg = "#2E2C2F"

  highlight_telescope(colors)
  transaprent()
end

if vim.g.theme == "paper" then
  defaultCursor()

  vim.cmd [[
    set background=dark
    colorscheme PaperColor

    hi CursorLineNr guibg=#303030
    hi WinSeparator guifg=#606765 guibg=NONE
    hi Visual guibg=#8787AF guifg=#000009

    hi NamuPreview guibg=#303030 guifg=#ebdbb2

    hi NonText guibg=NONE
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

if vim.g.theme == "light" then
  vim.opt.guicursor = "i:block"

  vim.cmd [[
    set background=light
    colorscheme catppuccin
  ]]

  transaprent()
  gitTransparent()

  local colors = {}

  colors.input = "#F7F1DC"
  colors.result = "#F7F1DC"
  colors.counter = "#2AA198"
  colors.selection_bg = "#CCD0DA"

  highlight_telescope(colors)
end


vim.cmd.highlight("DiagnosticUnderlineError gui=undercurl")
vim.cmd.highlight("DiagnosticUnderlineWarn gui=undercurl")
