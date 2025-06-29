local reload_theme = require('utils.reload_theme').reload_theme

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      background = { -- :h background
        light = 'latte',
        dark = vim.g.default_dark_catppuccin_theme,
      },
      integrations = {
        mason = true,
        neotest = true,
        neotree = true,
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
      transparent_background = false,
      show_end_of_buffer = false,
      integration_default = false,
      color_overrides = {
        macchiato = {
          base = '#2A2C35',
          crust = '#21252B',
          mantle = '#2B2637',
        },
        latte = {
          rosewater = '#d73a49',
          flamingo = '#d73a49',
          red = '#d73a49',
          maroon = '#d73a49',
          pink = '#bf3989',
          mauve = '#6f42c1',
          peach = '#e36209',
          yellow = '#9a6700',
          green = '#22863a',
          teal = '#1b7c83',
          sky = '#1b7c83',
          sapphire = '#1b7c83',
          blue = '#005cc5',
          lavender = '#005cc5',
          text = '#24292e',
          subtext1 = '#24292f',
          subtext0 = '#32383f',
          overlay2 = '#424a53',
          overlay1 = '#57606a',
          overlay0 = '#6e7781',
          surface2 = '#8c8c8c',
          surface1 = '#d1d1d1',
          surface0 = '#e6e6e6',
          base = '#FFFFFF',
          mantle = '#e6e9ef',
          crust = '#ebebeb',
        },
      },
      highlight_overrides = {
        -- macchiato = function(colors)
        --   return {
        --     Normal = { bg = 'NONE' },
        --     NormalNC = { bg = 'NONE' },
        --   }
        -- end,
        all = function(colors)
          return {
            WinBar = { fg = colors.mauve },
            DiagnosticVirtualTextError = { bg = 'NONE', fg = colors.red },
            DiagnosticVirtualTextWarn = { bg = 'NONE', fg = colors.yellow },
            DiagnosticVirtualTextInfo = { bg = 'NONE', fg = colors.blue },
            DiagnosticVirtualTextHint = { bg = 'NONE', fg = colors.teal },
            DiagnosticUnderlineError = { sp = colors.red, style = { 'undercurl' } },
            DiagnosticUnderlineWarn = { sp = colors.yellow, style = { 'undercurl' } },
            SnacksIndent = { fg = colors.surface1 },
            IblIndent = { fg = colors.surface1 },

            -- surface1:
            SignColumn = { fg = colors.surface2 }, -- column where |signs| are displayed
            SignColumnSB = { fg = colors.surface2 }, -- column where |signs| are displayed

            LineNr = { fg = colors.surface2 }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' o…
            TreesitterContextLineNumber = { fg = colors.surface2 },
            CursorLineNr = { fg = colors.blue }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.

            DapUIUnavailable = { fg = colors.surface2 },

            GitSignsCurrentLineBlame = { fg = colors.surface2 },

            -- More contrast menus:
            Pmenu = { bg = colors.crust, fg = colors.overlay0 }, -- Popup menu: normal item.
            CmpCursorLine = { bg = colors.green, style = { 'bold' }, fg = colors.surface0 }, -- Popup menu: selected item.

            -- NeoTreeNormal = { bg = colors.crust },
            -- NeoTreeNormalNC = { bg = colors.crust },

            -- More contrast for window separator:
            WinSeparator = { fg = colors.surface2 }, -- Separator between windows.
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
        reload_theme()
      end,
      set_light_mode = function()
        vim.g.theme = vim.g.default_white_theme
        reload_theme()
      end,
      update_interval = 3000,
      fallback = 'dark',
    },
  },
}
