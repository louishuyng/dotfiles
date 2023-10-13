local theme = require("ui.main_colors")
local colors = theme[vim.g.main_theme]

local has_value = require("utils.has_value")

-- functions for setting highlights
local fg = require("utils.highlight").fg
local fg_bg = require("utils.highlight").fg_bg
local bg = require("utils.highlight").bg

local default_theme_list = {"vscode", "osaka", "minimalist"}
local default_theme = has_value(default_theme_list, vim.g.main_theme)

local ui = {hl_override = "", italic_comments = false}

local black = colors.black
local black2 = colors.black2
local pure_black = colors.pure_black
local blue = colors.blue
local green = colors.green
local grey = colors.grey
local grey_fg = colors.grey_fg
local grey_fg2 = colors.grey_fg2
local purple = colors.purple
local red = colors.red
local white = colors.white
local yellow = colors.yellow
local orange = colors.orange
local cyan = colors.cyan
local winbar = colors.winbar
local statusline = colors.statusline
local winbar_inactive = colors.winbar_inactive
local color_bg = colors.bg
local color_fg = colors.fg
local cursorline = colors.cursorline
local treebg = colors.treebg

-- Basic
vim.cmd([[
  hi LspDiagnosticsLineNrError guifg=#DC322F guibg=#312a34 gui=bold
  hi LspDiagnosticsLineNrWarning guifg=#B58900 guibg=#312e3a gui=bold
]])

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
fg_bg('St_cwd', red, statusline)

-- Breadcrumb
fg('LspCodeLens', "#ea6962")

-- Telescope
fg_bg('TelescopePromptTitle', black, green, 'bold')
fg_bg('TelescopePreviewTitle', black, cyan, 'bold')

-- DAP
fg_bg('DapStopped', black, green)

-- Fold
bg("Folded", "#071C2E")

if default_theme then
  vim.cmd([[
    hi TabLineFill guifg=#4E4E4E
    hi TabLineSel guibg=black guifg=#d4d4d4
    hi SignColumn guibg=NONE
    hi FoldColumn guibg=NONE
    hi VertSplit guifg=#4E4E4E guibg=NONE
    hi CursorLineNr guibg=NONE
    hi CursorLine guibg=#323232
    hi NonText guibg=NONE guifg=#585858

    hi clear Search
    hi Search guibg=#585858 guifg=NONE
  ]])

  return
end

-- HL based on setting
if vim.g.main_theme == 'linux' then
  vim.cmd([[
    hi VertSplit guifg=#323232 guibg=bg cterm=NONE
    hi CursorLine guibg=#323232
    hi TabLineFill guifg=#000000
    hi TabLineSel guibg=#0000F5 guifg=white

    hi StatusLine guibg=NONE guifg=#abb2bf
    hi SignColumn guibg=NONE
    hi FoldColumn guibg=NONE

    hi Normal guibg=NONE
    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
    hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE
    hi CursorLine guibg=#323232 guifg=NONE
  ]])
end

if vim.g.main_theme == 'dracula' or vim.g.main_theme == 'edge' then
  bg("CursorLine", cursorline)
  fg("VertSplit", "#282c34")
end
