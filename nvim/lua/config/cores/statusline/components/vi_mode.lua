local vi_mode_utils = require 'feline.providers.vi_mode'

local vi_mode = {
  left = {
    provider = function()
      return '   '
    end,
    hl = function()
      local val = {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color(),
        -- fg = colors.bg
      }
      return val
    end,
    right_sep = ' '
  },
  right = {
    -- provider = '▊',
    provider = '' ,
    hl = function()
      local val = {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color()
      }
      return val
    end,
    left_sep = ' ',
    right_sep = ' '
  }
}

return vi_mode
