return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      background = { -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      integrations = {
        mason = true,
        neotest = true,
        noice = true,
        copilot_vim = true,
        diffview = true,
        snacks = {
          enabled = true,
          indent_scope_color = '', -- catppuccin color (eg. `lavender`) Default: text
        },
        lsp_trouble = true,
        which_key = true,
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
          rosewater = '#cc7983',
          flamingo = '#bb5d60',
          pink = '#d54597',
          mauve = '#a65fd5',
          red = '#b7242f',
          maroon = '#db3e68',
          peach = '#e46f2a',
          yellow = '#bc8705',
          green = '#1a8e32',
          teal = '#00a390',
          sky = '#089ec0',
          sapphire = '#0ea0a0',
          blue = '#017bca',
          lavender = '#8584f7',
          text = '#444444',
          subtext1 = '#555555',
          subtext0 = '#666666',
          overlay2 = '#777777',
          overlay1 = '#888888',
          overlay0 = '#999999',
          surface2 = '#aaaaaa',
          surface1 = '#bbbbbb',
          surface0 = '#cccccc',
          base = '#ffffff',
          mantle = '#eeeeee',
          crust = '#dddddd',
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
          luafile ~/.dotfiles/nvim/lua/ui/buffer.lua
          luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
        ]])
      end,
      set_light_mode = function()
        vim.g.theme = vim.g.default_white_theme
        vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
          luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
          luafile ~/.dotfiles/nvim/lua/ui/buffer.lua
          luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
        ]])
      end,
      update_interval = 3000,
      fallback = 'dark',
    },
  },
}
