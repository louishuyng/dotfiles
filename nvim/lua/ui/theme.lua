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

if vim.g.main_theme == 'gruvbox' then
  vim.g.gruvbox_material_background = "hard"
  vim.cmd('colorscheme gruvbox-material')
end

if vim.g.main_theme == 'edge' then
  vim.g.edge_transparent_background = 1
  vim.g.edge_better_performance = 1
  vim.cmd('colorscheme edge')
end

if vim.g.main_theme == 'catppuccin' then
  require("catppuccin").setup {
    flavour = "mocha" -- latte, frappe, macchiato, mocha
  }

  vim.cmd('colorscheme catppuccin')
end
