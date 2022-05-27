local colors = require 'ui.main_colors'

return {
  provider = function()
    if next(vim.lsp.buf_get_clients()) ~= nil then
      return "  LSP"
    else
      return ""
    end
  end,
  hl = {fg = colors.grey_fg2, bg = colors.statusline_bg}
}
