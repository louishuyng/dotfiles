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

vim.cmd([[
  hi Search cterm=NONE ctermfg=NONE ctermbg=240 guifg=NONE guibg=#585858
  hi DiffText cterm=NONE ctermfg=NONE ctermbg=23 guifg=NONE guibg=#005f5f
  hi FloatermBorder guifg=#55E579
  hi FloatBorder guibg=NONE
  hi VertSplit guifg=#23272e guibg=bg cterm=NONE
  hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
  hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE
  hi NormalFloat guibg=NONE
  hi DeniteBackground ctermfg=NONE ctermbg=24 cterm=NONE guifg=#ffffff guibg=#000000 gui=NONE
  hi LineNr guibg=NONE guifg=grey
  hi Visual guibg=#323232 guifg=NONE
  hi SignColumn guibg=NONE
]])
