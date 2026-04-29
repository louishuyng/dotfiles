local opts = {
  transparent_background = false,
  color_overrides = {
    mocha = {
      -- Syntax: Material theme (vibrant, saturated)
      -- rosewater = '#F78C6C',
      -- flamingo = '#FF9CAC',
      -- pink = '#FF9CAC',
      -- mauve = '#C792EA',
      -- red = '#FF5370',
      -- maroon = '#f07178',
      -- peach = '#F78C6C',
      -- yellow = '#FFCB6B',
      -- green = '#C3E88D',
      -- teal = '#89DDFF',
      -- sky = '#89DDFF',
      -- sapphire = '#82AAFF',
      -- blue = '#82AAFF',
      -- lavender = '#d2a8ff',
      -- -- Text: GitHub Dark
      -- text = '#e6edf3',
      -- subtext1 = '#c9d1d9',
      -- subtext0 = '#b1bac4',
      -- overlay2 = '#8b949e',
      -- overlay1 = '#6e7681',
      -- overlay0 = '#484f58',
      -- Surfaces: GitHub Dark
      -- surface2 = '#30363d',
      -- surface1 = '#21262d',
      -- surface0 = '#1e1e1e',
      -- base = '#0d1117',
      -- mantle = '#090c10',
      -- crust = '#010409',
    },
    latte = {
      rosewater = '#fdf7e8',
      flamingo = '#cb4b16',
      pink = '#d33682',
      mauve = '#6c71c4',
      red = '#dc322f',
      maroon = '#c03260',
      peach = '#cb4b1f',
      yellow = '#b58900',
      green = '#859900',
      teal = '#2aa198',
      sky = '#2398d2',
      sapphire = '#0077b3',
      blue = '#268bd2',
      lavender = '#7b88d3',
      text = '#657b83',
      subtext1 = '#586e75',
      subtext0 = '#073642',
      overlay2 = '#002b36',
      overlay1 = '#839496',
      overlay0 = '#93a1a1',
      base = '#fdf6e3',
      mantle = '#f7f1dc',
      crust = '#f5ecd7',
    },
  },
  highlight_overrides = {
    all = function(colors)
      return {
        TelescopeSelection = { fg = 'None', bg = colors.surface0 },
      }
    end,
  },
}

require('catppuccin').setup(opts)
vim.cmd.colorscheme 'catppuccin'

require('auto-dark-mode').setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.cmd.colorscheme 'catppuccin-macchiato'
    vim.o.background = 'dark'
  end,
  set_light_mode = function()
    vim.cmd.colorscheme 'catppuccin'
    vim.o.background = 'light'
  end,
})
