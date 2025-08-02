local helpers = require 'incline.helpers'
local devicons = require 'nvim-web-devicons'

local palettes = require('catppuccin.palettes')

require('incline').setup {
  window = {
    padding = 0,
    margin = { horizontal = 0, vertical = 0 },
  },
  render = function(props)
    local C = palettes.get_palette(flavour)

    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
    if filename == '' then
      filename = '[No Name]'
    end
    local ft_icon, ft_color = devicons.get_icon_color(filename)
    local modified = vim.bo[props.buf].modified
    local res = {
      modified and { ' +', guifg = C.red, guibg = C.base } or '',
      ft_icon and { ' ', ft_icon, ' ', guifg = ft_color, guibg = C.base } or '',
      { filename, guifg = C.text, guibg = C.base },
      guibg = C.base,
    }

    return res
  end,
}
