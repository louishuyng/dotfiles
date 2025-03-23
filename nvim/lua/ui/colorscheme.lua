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

    colorscheme duskfox

    hi Normal guibg=#171717
    hi NormalNC guibg=#171717

    hi BufferCurrent guibg=NONE guifg=white
    hi BufferCurrentMod guibg=NONE guifg=white
    hi BufferCurrentError guibg=NONE guifg=#F00000
    hi BufferInactiveError guibg=#191726 guifg=#F00000
    hi BufferCurrentHINT guibg=NONE guifg=#D8AF5F
    hi BufferInactiveHINT guibg=#191726 guifg=#D8AF5F

    hi WinSeparator guifg=#9D79D6 guibg=NONE
  ]]

  transaprent()

  local colors = {}

  colors.input = "#191726"
  colors.result = "#191726"
  colors.counter = "#9D79D6"
  colors.selection_bg = "#373354"
  colors.title = "#82A5D5"
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
    hi BufferCurrentError guibg=NONE guifg=#F00000
    hi BufferInactiveError guibg=NONE guifg=#F00000
    hi BufferVisibleError guibg=NONE guifg=#F00000
    hi BufferCurrentHINT guibg=NONE guifg=#D8AF5F
    hi BufferInactiveHINT guibg=NONE guifg=#D8AF5F
    hi BufferVisibleHINT guibg=NONE guifg=#D8AF5F
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
    colorscheme dayfox

    hi NonText guibg=NONE
    hi BufferCurrent guibg=#2748A9 guifg=white
    hi BufferCurrentMod guibg=#2748A9 guifg=white
    hi BufferCurrentError guibg=#2748A9 guifg=#F00000
    hi BufferInactiveError guibg=#E5DCD4 guifg=#F00000
    hi BufferCurrentHINT guibg=NONE guifg=#D8AF5F
    hi BufferInactiveHINT guibg=#E5DCD4 guifg=#D8AF5F
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
