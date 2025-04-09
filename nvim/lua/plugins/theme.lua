return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      background = { -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      color_overrides = {
        mocha = {
          text = '#F4CDE9',
          subtext1 = '#DEBAD4',
          subtext0 = '#C8A6BE',
          overlay2 = '#B293A8',
          overlay1 = '#9C7F92',
          overlay0 = '#866C7D',
          surface2 = '#705867',
          surface1 = '#5A4551',
          surface0 = '#44313B',
          base = '#352939',
          mantle = '#211924',
          crust = '#1a1016',
        },
        latte = {
          rosewater = '#c14a4a',
          flamingo = '#c14a4a',
          red = '#c14a4a',
          maroon = '#c14a4a',
          pink = '#945e80',
          mauve = '#945e80',
          peach = '#c35e0a',
          yellow = '#b47109',
          green = '#6c782e',
          teal = '#4c7a5d',
          sky = '#4c7a5d',
          sapphire = '#4c7a5d',
          blue = '#45707a',
          lavender = '#45707a',
          text = '#654735',
          subtext1 = '#73503c',
          subtext0 = '#805942',
          overlay2 = '#8c6249',
          overlay1 = '#8c856d',
          overlay0 = '#a69d81',
          surface2 = '#bfb695',
          surface1 = '#d1c7a3',
          surface0 = '#e3dec3',
          base = '#f9f5d7',
          mantle = '#f0ebce',
          crust = '#e8e3c8',
        },
      },
    },
  },
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      set_dark_mode = function()
        vim.g.theme = vim.g.default_black_theme
        vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
          luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
          luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
        ]])
      end,
      set_light_mode = function()
        vim.g.theme = vim.g.default_white_theme
        vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
          luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
          luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
        ]])
      end,
      update_interval = 3000,
      fallback = 'dark',
    },
  },
}
