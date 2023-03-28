local colors = require("ui.main_colors")

local ui = { hl_override = "", italic_comments = false }

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

-- Statusline
fg_bg("St_NormalMode", green, statusline)
fg_bg("St_InsertMode", purple, statusline)
fg_bg("St_TerminalMode", green, statusline)
fg_bg("St_VisualMode", blue, statusline)
fg_bg("St_ReplaceMode", orange, statusline)
fg_bg("St_SelectMode", blue, statusline)
fg_bg("St_CommandMode", green, statusline)
fg_bg("St_ConfirmMode", green, statusline)
fg_bg('St_gitIcons', grey, statusline)
fg_bg('St_lspError', red, statusline)
fg_bg('St_lspWarning', yellow, statusline)
fg_bg('St_LspHints', purple, statusline)
fg_bg('St_LspInfo', blue, statusline)
fg_bg('St_LspStatus', green, statusline)
fg_bg('St_LspProgress', red, statusline)
fg_bg('StText', grey_fg2, statusline)
fg_bg('St_ft', blue, statusline)
fg_bg('St_encode', orange, statusline)
fg_bg('St_cwd', red, statusline)

vim.cmd([[
  hi Search cterm=NONE ctermfg=NONE ctermbg=240 guifg=NONE guibg=#585858
  hi DiffText cterm=NONE ctermfg=NONE ctermbg=23 guifg=NONE guibg=#005f5f
  hi FloatermBorder guifg=#87AF87
  hi FloatBorder guibg=NONE
  hi VertSplit guifg=#23272e guibg=bg cterm=NONE
  hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
  hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#a9b665 gui=NONE
  hi NormalFloat guibg=NONE
  hi DeniteBackground ctermfg=NONE ctermbg=24 cterm=NONE guifg=#ffffff guibg=#000000 gui=NONE
  hi LineNr guibg=NONE guifg=grey
  hi Visual guibg=#323232 guifg=NONE
  hi CursorLine gui=underline cterm=underline guibg=NONE
  hi SignColumn guibg=NONE
  hi LspDiagnosticsLineNrError guifg=#ea6962 guibg=#312a34 gui=bold
  hi LspDiagnosticsLineNrWarning guifg=#e78a4e guibg=#312e3a gui=bold
  hi CursorLineNr guifg=#d3869b guibg=NONE
  hi VertSplit guibg=NONE guifg=#565c64
  hi Statusline guifg=#a6accd guibg=NONE gui=NONE
  hi StatuslineNC guifg=#7982b4 guibg=NONE gui=NONE
]])

-- Highlight line numbers for diagnostics
vim.fn.sign_define('DiagnosticSignError',
  { numhl = 'LspDiagnosticsLineNrError', text = '' })
vim.fn.sign_define('DiagnosticSignWarn',
  { numhl = 'LspDiagnosticsLineNrWarning', text = '' })
vim.fn.sign_define('DiagnosticSignInfo', { text = '' })
vim.fn.sign_define('DiagnosticSignHint', { text = '' })
