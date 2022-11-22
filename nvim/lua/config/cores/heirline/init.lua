local present, heirline = pcall(require, "heirline")
local colors = require("ui.main_colors")

if not present then return end

local utils = require("heirline.utils")

local StatusLines = require("config.cores.heirline.statusline").StatusLines

local function setup_colors()
  return {
    bg = colors.statusline,
    bright_bg = colors.statusline,
    bright_fg = colors.white,
    red = colors.red,
    dark_red = colors.red,
    green = colors.green,
    blue = colors.blue,
    gray = colors.gray,
    white = colors.white,
    constant = utils.get_highlight("Constant").fg,
    statement = utils.get_highlight("Statement").fg,
    special = utils.get_highlight("Special").fg,
    diag_warn = colors.yellow,
    diag_error = colors.red,
    diag_hint = colors.purple,
    diag_info = colors.green,
    git_del = colors.red,
    git_add = colors.green,
    git_change = colors.grey_fg
  }
end
heirline.load_colors(setup_colors())

heirline.setup(StatusLines)

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
