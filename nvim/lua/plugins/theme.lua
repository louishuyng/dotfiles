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
      highlight_overrides = {
        -- Increase contrast, which is not enough by default:
        latte = function(colors)
          return {
            TermCursor = { bg = colors.mauve },
            Identifier = { fg = colors.maroon },
            markdownCode = { fg = colors.maroon },
            markdownCodeBlock = { fg = colors.maroon },
            Substitute = { bg = colors.crust }, -- used for substitution hints
            Visual = { bg = colors.crust }, -- used for highlighting visual selection
            VisualNOS = { bg = colors.crust }, -- Visual mode selection when vim is "Not Owning the Selection".
            LspReferenceText = { bg = colors.crust }, -- used for highlighting "text" references
            LspReferenceRead = { bg = colors.crust }, -- used for highlighting "read" references
            LspReferenceWrite = { bg = colors.crust }, -- used for highlighting "write" references
            LspSignatureActiveParameter = { bg = colors.crust },
            MatchParen = { bg = colors.crust }, -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
            illuminatedWord = { bg = colors.crust },
            illuminatedCurWord = { bg = colors.crust },
            IlluminatedWordText = { bg = colors.crust },
            IlluminatedWordRead = { bg = colors.crust },
            IlluminatedWordWrite = { bg = colors.crust },
            RenderMarkdownCodeInline = { bg = colors.crust },
          }
        end,
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
