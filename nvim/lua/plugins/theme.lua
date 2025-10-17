return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    build = ':CatppuccinCompile',
    opts = {
      compile = {
        -- Compile the theme on startup
        enabled = true,
        path = vim.fn.stdpath('cache') .. '/catppuccin',
      },
      dim_inactive = {
        enabled = false,
        shade = 'dark',
        percentage = 0.3,
      },
      background = {
        light = 'latte',
        dark = vim.g.default_dark_catppuccin_theme,
      },
      integrations = {
        mason = true,
        dap = true,
        cmp = true,
        dap_ui = true,
        neotest = true,
        neotree = true,
        noice = true,
        copilot_vim = true,
        diffview = true,
        flash = true,
        snacks = {
          enabled = true,
          indent_scope_color = '', -- catppuccin color (eg. `lavender`) Default: text
        },
        lsp_trouble = true,
        which_key = true,
        treesitter_context = true,
        markdown = true,
        telescope = { enabled = true, style = 'nvchad' },
        mini = { enabled = true, indentscope_color = '' },
        semantic_tokens = true,
        gitsigns = true,
        render_markdown = true,
        treesitter = true,
        treesitter_context = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
      },
      transparent_background = false,
      show_end_of_buffer = false,
      integration_default = false,
      color_overrides = {
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
          surface2 = '#eee8d5',
          surface1 = '#ebecef',
          surface0 = '#ccd0da',
          base = '#fdf6e3',
          mantle = '#f7f1dc',
          crust = '#f5ecd7',
        },
        mocha = {
          rosewater = '#ec7279',
          flamingo = '#ec7279',
          pink = '#d38aea',
          mauve = '#d38aea',
          red = '#ec7279',
          maroon = '#ec7279',
          peach = '#deb974',
          yellow = '#deb974',
          green = '#a0c980',
          teal = '#5dbbc1',
          sky = '#5dbbc1',
          sapphire = '#5dbbc1',
          blue = '#6cb6eb',
          lavender = '#c5cdd9',
          text = '#c5cdd9',
          subtext1 = '#c5cdd9',
          subtext0 = '#758094',
          overlay2 = '#535c6a',
          overlay1 = '#535c6a',
          overlay0 = '#535c6a',
          surface2 = '#414550',
          surface1 = '#3b3e48',
          surface0 = '#363944',
          base = '#161616',
          mantle = '#0f0f0f',
          crust = '#0a0a0a',
        },
      },
      highlight_overrides = {
        mocha = function(colors)
          return {
            -- Normal = { bg = 'NONE' },
            -- NormalNC = { bg = 'NONE' },
          }
        end,
        all = function(color)
          return {
            NeoTreeDirectoryIcon = { fg = color.blue },
            NeoTreeDirectoryName = { fg = color.green },
            NeoTreeRootName = { fg = color.mauve },

            -- For base configs
            NormalFloat = { fg = color.text, bg = transparent_background and color.none or color.mantle },
            FloatBorder = {
              fg = transparent_background and color.blue or color.mantle,
              bg = transparent_background and color.none or color.mantle,
            },
            CursorLineNr = { fg = color.green },
            CursorLine = { bg = transparent_background and color.none or color.surface0 },
            LineNr = { fg = color.overlay1 },
            WinSeparator = { fg = color.overlay2, bg = 'NONE' },

            -- Tabline
            TabLineFill = { fg = color.lavender, bg = color.base },
            TabLineSel = { fg = color.subtext1, bg = color.surface1 },
            TabLine = { fg = color.overlay0, bg = color.surface0 },

            -- Editor
            Comment = { fg = color.overlay1 },
            CursorLineNR = { fg = color.yellow },

            -- Splits
            VertSplit = { fg = color.surface0 },

            -- Floats
            FloatNormal = { fg = color.text, bg = color.mantle },
            FloatBorder = { fg = color.surface2 },

            -- Noice
            NoiceCmdlineIcon = { fg = color.peach },
            NoiceCmdlineIconCmdline = { fg = color.peach },

            NoiceCmdlinePopupBorder = { fg = color.surface2 },
            NoiceCmdlinePopupBorderCmdline = { fg = color.surface2 },
            NoiceCmdlinePopupBorderSearch = { fg = color.surface2 },
            NoiceCmdlinePopupBorderFilter = { fg = color.surface2 },
            NoiceCmdlinePopupBorderlua = { fg = color.surface2 },

            -- Mason Colours
            MasonHeader = { fg = color.base, bg = color.peach },
            MasonHeaderSecondary = { fg = color.base, bg = color.teal },

            MasonHighlight = { fg = color.teal },
            MasonHighlightBlock = { bg = color.teal, fg = color.base },
            MasonHighlightBlockBold = { bg = color.teal, fg = color.base, bold = true },

            MasonHighlightSecondary = { fg = color.red },
            MasonHighlightBlockSecondary = { bg = color.red, fg = color.base },
            MasonHighlightBlockBoldSecondary = { bg = color.red, fg = color.base, bold = true },

            MasonLink = { fg = color.rosewater },

            MasonMuted = { fg = color.overlay1 },
            MasonMutedBlock = { bg = color.surface0, fg = color.overlay1 },
            MasonMutedBlockBold = { bg = color.surface0, fg = color.overlay1, bold = true },

            MasonError = { fg = color.red },

            MasonHeading = { bold = true },

            --ToggleTerm Custom Colours
            LazygitBorder = { fg = color.surface2 },

            --Nvim-Notify Colours
            NotifyERRORBorder = { fg = color.surface2, bg = color.base },
            NotifyWARNBorder = { fg = color.surface2, bg = color.base },
            NotifyINFOBorder = { fg = color.surface2, bg = color.base },
            NotifyDEBUGBorder = { fg = color.surface2, bg = color.base },
            NotifyTRACEBorder = { fg = color.surface2, bg = color.base },

            NotifyERRORIcon = { fg = color.red, bg = color.base },
            NotifyWARNIcon = { fg = color.yellow, bg = color.base },
            NotifyINFOIcon = { fg = color.green, bg = color.base },
            NotifyDEBUGIcon = { fg = color.surface2, bg = color.base },
            NotifyTRACEIcon = { fg = color.lavender, bg = color.base },

            NotifyERRORTitle = { fg = color.red, bg = color.base },
            NotifyWARNTitle = { fg = color.yellow, bg = color.base },
            NotifyINFOTitle = { fg = color.green, bg = color.base },
            NotifyDEBUGTitle = { fg = color.surface2, bg = color.base },
            NotifyTRACETitle = { fg = color.lavender, bg = color.base },

            NotifyERRORBody = { fg = color.text, bg = color.base },
            NotifyWARNBody = { fg = color.text, bg = color.base },
            NotifyINFOBody = { fg = color.text, bg = color.base },
            NotifyDEBUGBody = { fg = color.text, bg = color.base },
            NotifyTRACEBody = { fg = color.text, bg = color.base },

            -- For native lsp configs
            LspInfoBorder = { link = 'FloatBorder' },

            -- For mason.nvim
            MasonNormal = { link = 'NormalFloat' },

            -- For indent-blankline
            IblIndent = { fg = color.surface0 },
            IblScope = { fg = color.surface2, style = { 'bold' } },

            -- For nvim-cmp and wilder.nvim
            Pmenu = { fg = color.overlay2, bg = transparent_background and color.none or color.mantle },
            PmenuBorder = { fg = color.surface1, bg = transparent_background and color.none or color.base },
            PmenuSel = { bg = color.green, fg = color.base },
            CmpItemAbbr = { fg = color.overlay2 },
            CmpItemAbbrMatch = { fg = color.blue, style = { 'bold' } },
            CmpDoc = { link = 'NormalFloat' },
            CmpDocBorder = {
              fg = transparent_background and color.surface1 or color.mantle,
              bg = transparent_background and color.none or color.mantle,
            },

            -- For fidget
            FidgetTask = { bg = color.none, fg = color.surface2 },
            FidgetTitle = { fg = color.blue, style = { 'bold' } },

            -- For nvim-notify
            NotifyBackground = { bg = color.base },

            -- For neotree

            -- For trouble.nvim
            TroubleNormal = { bg = transparent_background and color.none or color.base },
            TroubleNormalNC = { bg = transparent_background and color.none or color.base },

            -- For telescope.nvim
            TelescopeMatching = { fg = color.lavender },
            TelescopeResultsDiffAdd = { fg = color.green },
            TelescopeResultsDiffChange = { fg = color.yellow },
            TelescopeResultsDiffDelete = { fg = color.red },

            -- For treesitter
            ['@keyword.return'] = { fg = color.pink, style = clear },
            ['@error.c'] = { fg = color.none, style = clear },
            ['@error.cpp'] = { fg = color.none, style = clear },
          }
        end,
      },
    },
  },
  {
    'f-person/auto-dark-mode.nvim',
    lazy = false,
    opts = {
      set_dark_mode = function()
        local reload_theme = require('utils.reload_theme').reload_theme

        vim.g.theme = vim.g.default_dark_theme
        reload_theme()
      end,
      set_light_mode = function()
        local reload_theme = require('utils.reload_theme').reload_theme

        vim.g.theme = vim.g.default_light_theme
        reload_theme()
      end,
      update_interval = 10000,
      fallback = 'dark',
    },
  },
}
