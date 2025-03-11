local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope
local diagnosticTransparent = highlight_utils.diagnosticTransparent

local function defaultCursor()
  vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
end

if vim.g.theme == "catppuccin" then
  defaultCursor()

  vim.cmd [[
    set background=dark

    colorscheme catppuccin

    hi WinSeparator guifg=#CA9EE6 guibg=NONE
  ]]

  transaprent()

  local colors = {}

  colors.input = "#262626"
  colors.result = "#262626"
  colors.counter = "#739B79"
  colors.selection_bg = "#32302F"
  colors.title = "#739B79"
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
    hi BufferCurrent guibg=NONE guifg=white
    hi BufferCurrentMod guibg=NONE guifg=white
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
    colorscheme solarized

    hi NonText guibg=NONE
  ]]

  transaprent()
  gitTransparent()

  local colors = {}

  colors.input = "#EEE8D5"
  colors.result = "#EEE8D5"
  colors.counter = "#2AA198"
  colors.selection_bg = "#FCF3DB"

  highlight_telescope(colors)
end
