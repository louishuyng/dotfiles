local present, heirline = pcall(require, "heirline")

if not present then return end

local utils = require("heirline.utils")

local StatusLines = require("config.cores.heirline.statusline").StatusLines
local TabLine = require("config.cores.heirline.tabline").TabLine

local function setup_colors()
  return {
    bg = utils.get_highlight("Normal").bg,
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("TabLine").fg,
    white = utils.get_highlight("TabLineSel").fg,
    orange = utils.get_highlight("Constant").fg,
    purple = utils.get_highlight("Statement").fg,
    cyan = utils.get_highlight("Special").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("diffDeleted").fg,
    git_add = utils.get_highlight("diffAdded").fg,
    git_change = utils.get_highlight("diffChanged").fg
  }
end
heirline.load_colors(setup_colors())

heirline.setup(StatusLines, TabLine)

vim.api.nvim_create_augroup("Heirline", {clear = true})

vim.cmd(
    [[au Heirline FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local colors = setup_colors()
    utils.on_colorscheme(colors)
  end,
  group = "Heirline"
})
