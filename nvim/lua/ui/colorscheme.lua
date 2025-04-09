local highlight_utils = require 'ui.highlight_utils'

local transaprent = highlight_utils.transaprent
local gitTransparent = highlight_utils.gitTransparent
local highlight_telescope = highlight_utils.highlight_telescope
local diagnosticTransparent = highlight_utils.diagnosticTransparent

if vim.g.theme == 'night' then
  vim.cmd [[
    set background=dark
    colorscheme catppuccin

    "hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#34302C gui=NONE
    "hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#1c1c1c guibg=#85B695 gui=NONE
  ]]

  transaprent()
end

if vim.g.theme == 'light' then
  vim.cmd [[
    set background=light
    colorscheme catppuccin

    hi NeoTreeNormal guibg=NONE
    hi NeoTreeNormalNC guibg=NONE
  ]]

  transaprent()
  gitTransparent()
end

local flavour = vim.g.theme == 'night' and 'mocha' or 'latte'

local C = require('catppuccin.palettes').get_palette(flavour)

local colors = {}

colors.input = C.mantle
colors.result = C.mantle
colors.counter = C.green
colors.selection_bg = C.base
colors.title = C.yellow
colors.title_bg = C.crust

highlight_telescope(colors)

vim.cmd.highlight('DiagnosticUnderlineError gui=undercurl')
vim.cmd.highlight('DiagnosticUnderlineWarn gui=undercurl')
