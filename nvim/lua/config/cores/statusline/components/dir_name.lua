local colors = require 'ui.main_colors'
local separator_style = require 'ui.statusline_seperator_style'

return {
  provider = function()
    local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    return "  " .. dir_name .. " "
  end,

  hl = {fg = colors.status_line_fg, bg = colors.status_line},
  right_sep = {
    str = separator_style.right,
    hi = {fg = colors.status_line_fg, bg = colors.status_line}
  }
}
