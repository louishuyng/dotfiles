local navic = require("nvim-navic")

local winbar_components = {active = {{}, {}, {}}, inactive = {{}, {}, {}}}

-- LEFT

-- nvimGps
winbar_components.active[1][1] = {
  provider = function() return navic.get_location() end,
  enabled = function() return navic.is_available() end,
  hl = {fg = 'white', style = 'bold'}
}

-- RIGHT

-- INACTIVE

-- fileType
winbar_components.inactive[1][1] = {
  provider = 'file_type',
  hl = {fg = 'black', bg = 'cyan', style = 'bold'},
  left_sep = {str = ' ', hl = {fg = 'NONE', bg = 'cyan'}},
  right_sep = {{str = ' ', hl = {fg = 'NONE', bg = 'cyan'}}, ' '}
}

return winbar_components
