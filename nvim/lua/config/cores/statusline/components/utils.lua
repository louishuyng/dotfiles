local colors = require 'ui.statusline_colors'

local utils = {
  line_percentage = {
    provider = 'line_percentage',
    left_sep = ' ',
    hl = {
      style = 'bold'
    }
  },
  scroll_bar = {
    provider = 'scroll_bar',
    left_sep = ' ',
    hl = {
      fg = colors.blue,
      style = 'bold'
    }
  }
}

return utils
