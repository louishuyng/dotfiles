return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
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
        all = function(color)
          return {
            -- Normal = { bg = 'NONE' },
            -- NormalNC = { bg = 'NONE' },
            -- For base configs
            NormalFloat = { fg = color.text, bg = transparent_background and color.none or color.mantle },
            FloatBorder = {
              fg = transparent_background and color.blue or color.mantle,
              bg = transparent_background and color.none or color.mantle,
            },
            CursorLineNr = { fg = color.green },
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
            DiagnosticVirtualTextError = { bg = color.none },
            DiagnosticVirtualTextWarn = { bg = color.none },
            DiagnosticVirtualTextInfo = { bg = color.none },
            DiagnosticVirtualTextHint = { bg = color.none },
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

            -- For nvim-tree
            NvimTreeRootFolder = { fg = color.pink },
            NvimTreeIndentMarker = { fg = color.surface2 },

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
}
