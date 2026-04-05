local dark_opts = {
  style = 'moon',
  transparent = true,
  terminal_colors = true,
  lualine_bold = true,

  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = { bold = true },
    variables = {},
    sidebars = 'dark',
    floats = 'dark',
  },

  on_colors = function(c)
    c.bg = '#1A1B26'
    c.bg_dark = '#0b0d12'
    c.bg_float = '#0d0f16'
    c.bg_popup = '#0d0f16'
    c.bg_sidebar = '#0b0d12'

    c.fg = '#9aa3c2'
    c.fg_dark = '#6b7699'
    c.fg_gutter = '#363d57'
    c.comment = '#4e5a7a'

    c.blue = '#5d7fcc'
    c.magenta = '#9172d4'
    c.green1 = '#4fa89a'
  end,

  on_highlights = function(hl, c) end,
}

local light_opts = {
  style = 'day',
  transparent = false,
  terminal_colors = true,
  lualine_bold = true,

  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = { bold = true },
    variables = {},
    sidebars = 'light',
    floats = 'light',
  },
}

require('tokyonight').setup(dark_opts)
vim.cmd.colorscheme 'tokyonight'

require('auto-dark-mode').setup({
  update_interval = 1000,
  set_dark_mode = function()
    require('tokyonight').setup(dark_opts)
    vim.cmd.colorscheme 'tokyonight'
    vim.o.background = 'dark'
  end,
  set_light_mode = function()
    require('tokyonight').setup(light_opts)
    vim.cmd.colorscheme 'tokyonight'
    vim.o.background = 'light'
  end,
})
