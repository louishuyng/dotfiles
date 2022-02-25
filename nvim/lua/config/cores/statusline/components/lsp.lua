local colors = require 'ui.statusline_colors'

local lsp = {
  name = {
    provider = 'lsp_client_names',
    -- left_sep = ' ',
    right_sep = ' ',
    -- icon = '  ',
    icon = '慎',
    hl = {
      fg = colors.yellow
    }
  }
}

return lsp
