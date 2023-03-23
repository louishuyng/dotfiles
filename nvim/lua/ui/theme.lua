local colors = require("ui.main_colors")
local fg_bg = require("utils.highlight").fg_bg

local icons = require('nvim-web-devicons').get_icons()
for _, icon_data in pairs(icons) do
  if icon_data.color and icon_data.name then
    local hl_group = icon_data.name and 'StatuslineDevIcon' .. icon_data.name
    if hl_group then
      local colors = {fg = icon_data.color, bg = colors.statusline}

      vim.api.nvim_set_hl(0, hl_group, vim.tbl_extend('force', {}, colors, {
        fg = colors.fg or 'NONE',
        bg = colors.bg or 'NONE',
        sp = colors.sp or 'NONE'
      }))
    end
  end
end

local base16 = require 'base16'
local theme = base16.theme_from_array {
  "000000", "3a3c4e", "4d4f68", "626483", "62d6e8", "e9e9f4", "f1f2f8",
  "f7f7fb", "c197fd", "FFB86C", "62d6e8", "F1FA8C", "8BE9FD", "50fa7b",
  "ff86d3", "F8F8F2"
}

base16(theme, true)
