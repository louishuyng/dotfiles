local colors = require 'ui.main_colors'
local separator_style = require 'ui.statusline_seperator_style'

return {
  provider = function()
    local filename = vim.fn.expand "%:t"
    local extension = vim.fn.expand "%:e"
    local icon = require("nvim-web-devicons").get_icon(filename, extension)
    if icon == nil then
      icon = " "
      return icon
    end
    return " " .. icon .. " " .. filename .. " "
  end,
  hl = {fg = colors.status_line_fg, bg = colors.status_line},

  right_sep = {
    str = separator_style.right,
    hl = {fg = colors.status_line_fg, bg = colors.status_line}
  }
}
