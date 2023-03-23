local colors = require("ui.main_colors")

local ui = {hl_override = "", italic_comments = false}

local black = colors.black
local black2 = colors.black2
local pure_black = colors.pure_black
local blue = colors.blue
local green = colors.green
local grey = colors.grey
local grey_fg = colors.grey_fg
local grey_fg2 = colors.grey_fg2
local custom_bg = colors.custom_bg
local custom_bg2 = colors.custom_bg2
local purple = colors.purple
local red = colors.red
local white = colors.white
local yellow = colors.yellow
local orange = colors.orange
local cyan = colors.cyan
local custom_bg3 = colors.custom_bg3
local winbar = colors.winbar
local statusline = colors.statusline
local winbar_inactive = colors.winbar_inactive

-- functions for setting highlights
local fg = require("utils.highlight").fg
local fg_bg = require("utils.highlight").fg_bg
local bg = require("utils.highlight").bg

-- [[ Plugin Highlights
-- Alpha
fg("AlphaHeader", green)
fg("AlphaButtons", blue)
fg("AlphaFooter", yellow)

-- Git signs
fg_bg("diffDeleted", red, "NONE")
fg_bg("diffAdded", green, "NONE")
fg_bg("diffChanged", purple, "NONE")

fg_bg("DiffDelete", red, "NONE")
fg_bg("DiffAdd", green, "NONE")
fg_bg("DiffChange", purple, "NONE")

fg_bg("GitSignsDelete", red, "NONE")
fg_bg("GitSignsChange", purple, "NONE")
fg_bg("GitSignsAdd", green, "NONE")

-- Lsp diagnostics
fg("DiagnosticHint", purple)
fg("DiagnosticError", red)
fg("DiagnosticWarn", yellow)
fg("DiagnosticInformation", green)

-- Navic
fg("NavicSeparator", '#55E579')

-- Buffer
bg("BufferLineTabSeparator", "NONE")
bg("BufferLineTabSeparatorSelected", "NONE")

-- Statusline
fg_bg("StatuslineAccent", cyan, statusline)
fg_bg("StatuslineBoolean", orange, statusline)
fg_bg("StatuslineError", red, statusline)
fg_bg("StatuslineWarning", orange, statusline)
fg_bg("StatuslineSuccess", green, statusline)
fg_bg("StatuslinePending", yellow, statusline)
fg_bg("StatuslineNormal", cyan, statusline)
fg_bg("StatuslineNormal", cyan, statusline)
fg_bg("StatuslineInsert", green, statusline)
fg_bg("StatuslineReplace", orange, statusline)
fg_bg("StatuslineVisual", purple, statusline)
fg_bg("StatuslineCommand", yellow, statusline)
fg_bg("StatuslineCommand", yellow, statusline)
fg_bg("StatuslineBlue", blue, statusline)

vim.cmd([[
  hi Search cterm=NONE ctermfg=NONE ctermbg=240 guifg=NONE guibg=#585858
  hi DiffText cterm=NONE ctermfg=NONE ctermbg=23 guifg=NONE guibg=#005f5f
  hi FloatermBorder guifg=#87AF87
  hi FloatBorder guibg=NONE
  hi VertSplit guifg=#23272e guibg=bg cterm=NONE
  hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
  hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#50fa7b gui=NONE
  hi NormalFloat guibg=NONE
  hi DeniteBackground ctermfg=NONE ctermbg=24 cterm=NONE guifg=#ffffff guibg=#000000 gui=NONE
  hi LineNr guibg=NONE guifg=grey
  hi Visual guibg=#323232 guifg=NONE
  hi CursorLine gui=underline cterm=underline guibg=NONE
  hi SignColumn guibg=NONE
  hi LspDiagnosticsLineNrError guifg=#ff5370 guibg=#312a34 gui=bold
  hi LspDiagnosticsLineNrWarning guifg=#f78c6c guibg=#312e3a gui=bold
  hi Statusline guifg=#a6accd guibg=#1d1f2b gui=NONE
  hi StatuslineNC guifg=#7982b4 guibg=#1d1f2b gui=NONE
  hi CursorLineNr guifg=#BD93F9 guibg=NONE
]])

-- Highlight line numbers for diagnostics
vim.fn.sign_define('DiagnosticSignError',
                   {numhl = 'LspDiagnosticsLineNrError', text = ''})
vim.fn.sign_define('DiagnosticSignWarn',
                   {numhl = 'LspDiagnosticsLineNrWarning', text = ''})
vim.fn.sign_define('DiagnosticSignInfo', {text = ''})
vim.fn.sign_define('DiagnosticSignHint', {text = ''})
