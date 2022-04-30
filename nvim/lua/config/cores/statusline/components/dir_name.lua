local colors = require 'ui.main_colors'
local separator_style = require 'ui.statusline_seperator_style'

return {
  provider = function()
    local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    return "  " .. dir_name .. " "
  end,

  hl = {
    fg = colors.grey_fg2,
    bg = colors.lightbg2,
  },
  right_sep = {
    str = separator_style.right,
    hi = {
       fg = colors.lightbg2,
       bg = colors.statusline_bg,
    },
  },
}
