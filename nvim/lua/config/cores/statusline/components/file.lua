local colors = require 'ui.statusline_colors'

local function file_osinfo()
    local os = vim.bo.fileformat:upper()
    local icon
    if os == 'UNIX' then
        icon = ' '
    elseif os == 'MAC' then
        icon = ' '
    else
        icon = ' '
    end
    return icon .. os
end


local file = {
  info = {
    provider = {
      name = 'file_info',
      opts = {
        type = 'relative-short',
        file_readonly_icon = '  ',
        -- file_readonly_icon = '  ',
        -- file_readonly_icon = '  ',
        -- file_readonly_icon = '  ',
        -- file_modified_icon = '',
        file_modified_icon = '',
        -- file_modified_icon = 'ﱐ',
        -- file_modified_icon = '',
        -- file_modified_icon = '',
        -- file_modified_icon = '',
      }
    },
    hl = {
      fg = colors.blue,
      style = 'bold'
    }
  },
  encoding = {
    provider = 'file_encoding',
    left_sep = ' ',
    hl = {
      fg = colors.violet,
      style = 'bold'
    }
  },
  type = {
    provider = 'file_type'
  },
  os = {
    provider = file_osinfo,
    left_sep = ' ',
    hl = {
      fg = colors.violet,
      style = 'bold'
    }
  },
  position = {
    provider = 'position',
    left_sep = ' ',
    hl = {
      fg = colors.cyan,
    }
  },
}

return file
