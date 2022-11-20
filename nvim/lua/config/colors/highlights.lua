local colors = require("ui.main_colors")

local ui = {hl_override = "", italic_comments = false, transparency = false}

local black = colors.black
local black2 = colors.black2
local pure_black = colors.pure_black
local blue = colors.blue
local telescope_bg = colors.telescope_bg
local folder_bg = colors.folder_bg
local folder_fg = colors.folder_fg
local green = colors.green
local grey = colors.grey
local grey_fg = colors.grey_fg
local grey_fg2 = colors.grey_fg2
local nord_blue = colors.nord_blue
local custom_bg = colors.custom_bg
local custom_bg2 = colors.custom_bg2
local purple = colors.purple
local red = colors.red
local white = colors.white
local yellow = colors.yellow
local orange = colors.orange
local custom_bg3 = colors.custom_bg3
local statusline = colors.statusline
local winbar = colors.winbar
local winbar_inactive = colors.winbar_inactive

-- functions for setting highlights
local fg = require("utils.highlight").fg
local fg_bg = require("utils.highlight").fg_bg
local bg = require("utils.highlight").bg

-- Background
bg("Normal", custom_bg)
bg("NormalNC", custom_bg)
bg("EndOfBuffer", custom_bg)
bg("WinBar", winbar)
bg("WinBarNC", winbar_inactive)
bg("CursorLine", grey)

-- [[ Plugin Highlights

-- Alpha
fg("AlphaHeader", green)
fg("AlphaButtons", nord_blue)
fg("AlphaFooter", yellow)

-- Git signs
fg_bg("DiffAdd", blue, "NONE")
fg_bg("DiffText", nord_blue, "NONE")
fg_bg("DiffChange", grey_fg, "NONE")
fg_bg("DiffChangeDelete", red, "NONE")
fg_bg("DiffModified", red, "NONE")
fg_bg("DiffDelete", red, custom_bg)

fg_bg("diffDeleted", red, custom_bg)
fg_bg("diffAdded", green, custom_bg)
fg_bg("diffChanged", grey_fg, custom_bg)

-- Lsp diagnostics

fg("DiagnosticHint", purple)
fg("DiagnosticError", red)
fg("DiagnosticWarn", yellow)
fg("DiagnosticInformation", green)

-- NvimTree
fg("NvimTreeEmptyFolderName", folder_fg)
fg("NvimTreeEndOfBuffer", folder_bg)
fg("NvimTreeFolderIcon", folder_fg)
fg("NvimTreeFolderName", folder_fg)
fg("NvimTreeGitDirty", red)
fg("NvimTreeIndentMarker", white)
bg("NvimTreeNormal", folder_bg)
bg("NvimTreeNormalNC", folder_bg)
fg("NvimTreeOpenedFolderName", folder_fg)
fg("NvimTreeRootFolder", red .. " gui=underline") -- enable underline for root folder in nvim tree
fg_bg("NvimTreeStatuslineNc", folder_bg, folder_bg)
fg("NvimTreeVertSplit", folder_bg)
bg("NvimTreeVertSplit", folder_bg)
fg_bg("NvimTreeWindowPicker", red, black2)

-- Telescope
fg_bg("TelescopeBorder", telescope_bg, telescope_bg)
fg_bg("TelescopePromptBorder", black2, black2)
fg_bg("TelescopePromptNormal", white, black2)
fg_bg("TelescopePromptPrefix", red, black2)
bg("TelescopeNormal", telescope_bg)
fg_bg("TelescopePreviewTitle", black, green)
fg_bg("TelescopePromptTitle", black, red)
fg_bg("TelescopeResultsTitle", black, yellow)

bg("TelescopeSelection", black2)

-- Disable some highlight in nvim tree if transparency enabled
if ui.transparency then
  bg("Normal", "NONE")
  bg("EndOfBuffer", "NONE")
  bg("NormalFloat", "NONE")
  bg("NvimTreeNormal", "NONE")
  bg("NvimTreeNormalNC", "NONE")
  bg("NvimTreeStatusLineNC", "NONE")
  bg("NvimTreeVertSplit", "NONE")
  fg("NvimTreeVertSplit", grey)

  -- telescope
  bg("TelescopeBorder", "NONE")
  bg("TelescopePrompt", "NONE")
  bg("TelescopeResults", "NONE")
  bg("TelescopePromptBorder", "NONE")
  bg("TelescopePromptNormal", "NONE")
  bg("TelescopeNormal", "NONE")
  bg("TelescopePromptPrefix", "NONE")
  fg("TelescopeBorder", custom_bg)
  fg_bg("TelescopeResultsTitle", black, blue)
end
