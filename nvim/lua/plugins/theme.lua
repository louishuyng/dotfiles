return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {
      flavour = 'frappe', -- latte, frappe, macchiato, mocha
      background = {
        light = 'latte',
        dark = 'frappe',
      },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = 'dark',
        percentage = 0.15,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,
      styles = {
        comments = {},
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      -- Edge inspired color palette
      color_overrides = {
        -- edge dark theme
        frappe = {
          base = '#1e1e1e',
          mantle = '#33353f',
          crust = '#202023',
          text = '#c5cdd9',
          subtext1 = '#bcc5d1',
          subtext0 = '#9da9a0',
          overlay2 = '#7f8490',
          overlay1 = '#6b7089',
          overlay0 = '#535965',
          surface2 = '#414550',
          surface1 = '#3b3e48',
          surface0 = '#363944',
          rosewater = '#deb974',
          flamingo = '#deb974',
          pink = '#d38aea',
          mauve = '#d38aea',
          red = '#ec7279',
          maroon = '#ec7279',
          peach = '#deb974',
          yellow = '#deb974',
          green = '#a0c980',
          teal = '#5dbbc1',
          sky = '#5dbbc1',
          sapphire = '#6cb6eb',
          blue = '#6cb6eb',
          lavender = '#d38aea',
        },
        -- edge light theme
        latte = {
          base = '#fafafa',
          mantle = '#eef1f4',
          crust = '#dde2e7',
          text = '#4b505b',
          subtext1 = '#5a5f6b',
          subtext0 = '#6b717d',
          overlay2 = '#7a8089',
          overlay1 = '#8b919a',
          overlay0 = '#9ca2ab',
          surface2 = '#c9cdd3',
          surface1 = '#d5d9df',
          surface0 = '#e1e5eb',
          rosewater = '#be7e05',
          flamingo = '#be7e05',
          pink = '#b05ccc',
          mauve = '#b05ccc',
          red = '#d05858',
          maroon = '#d05858',
          peach = '#be7e05',
          yellow = '#be7e05',
          green = '#608e32',
          teal = '#3a8b84',
          sky = '#3a8b84',
          sapphire = '#5079be',
          blue = '#5079be',
          lavender = '#b05ccc',
        },
      },
      custom_highlights = function(colors)
        return {
          -- Dashboard
          AlphaHeader = { fg = colors.blue },
          AlphaFooter = { fg = colors.mauve },
          AlphaButtons = { fg = colors.text },
          AlphaShortcut = { fg = colors.yellow },
          AlphaButtonText = { fg = colors.text },
          AlphaButtonShortcut = { fg = colors.blue },

          -- Cursor and lines
          CursorLine = { bg = colors.surface0 },
          CursorLineNr = { fg = colors.yellow },
          LineNr = { fg = colors.overlay0 },

          -- Visual selection
          Visual = { bg = colors.surface1 },

          -- Floating windows
          FloatBorder = { fg = colors.base, bg = colors.base },
          NormalFloat = { bg = colors.base },

          -- Diff
          DiffAdd = { bg = colors.surface0 },
          DiffChange = { bg = colors.surface0 },
          DiffDelete = { bg = colors.surface0 },
          DiffText = { bg = colors.surface1 },

          -- Git signs
          GitSignsAdd = { fg = colors.green },
          GitSignsChange = { fg = colors.blue },
          GitSignsDelete = { fg = colors.red },

          -- Statusline
          StatusLine = { bg = colors.mantle, fg = colors.text },
          StatusLineNC = { bg = colors.crust, fg = colors.overlay0 },

          -- Window separators
          WinSeparator = { fg = colors.surface1, bg = 'NONE' },
          VertSplit = { fg = colors.surface1, bg = colors.base },

          -- Search
          Search = { bg = colors.surface1, fg = colors.text },
          IncSearch = { bg = colors.yellow, fg = colors.base },

          -- Match paren
          MatchParen = { bg = colors.surface1, fg = colors.sky },

          -- Indent
          IblIndent = { fg = colors.surface0 },
          IblScope = { fg = colors.surface1 },

          -- Tree - folders green
          NvimTreeFolderIcon = { fg = colors.green },
          NvimTreeFolderName = { fg = colors.green },
          NvimTreeOpenedFolderName = { fg = colors.green },
          NvimTreeRootFolder = { fg = colors.green },
          NeoTreeDirectoryIcon = { fg = colors.green },
          NeoTreeDirectoryName = { fg = colors.green },
          NeoTreeRootName = { fg = colors.mauve, style = { 'bold' } },

          -- Telescope borderless seamless UI
          TelescopeNormal = { bg = colors.mantle },
          TelescopeBorder = { fg = colors.mantle, bg = colors.mantle },
          TelescopePromptNormal = { bg = colors.mantle },
          TelescopePromptBorder = { fg = colors.mantle, bg = colors.mantle },
          TelescopePromptTitle = { fg = colors.base, bg = colors.blue },
          TelescopePreviewNormal = { bg = colors.mantle },
          TelescopePreviewBorder = { fg = colors.mantle, bg = colors.mantle },
          TelescopePreviewTitle = { fg = colors.base, bg = colors.green },
          TelescopeResultsNormal = { bg = colors.mantle },
          TelescopeResultsBorder = { fg = colors.mantle, bg = colors.mantle },
          TelescopeResultsTitle = { fg = colors.base, bg = colors.mauve },
          TelescopeSelection = { bg = colors.surface0, fg = colors.green },
          TelescopeSelectionCaret = { fg = colors.green },
          TelescopePromptPrefix = { fg = colors.green },
          TelescopeMatching = { fg = colors.green, style = { 'bold' } },

          -- Claude Code terminal (mantle background)
          SnacksTerminal = { bg = colors.mantle },
          SnacksTerminalNormal = { bg = colors.mantle },

          -- Treesitter syntax
          ['@function'] = { fg = colors.blue },
          ['@function.call'] = { fg = colors.blue },
          ['@function.builtin'] = { fg = colors.blue },
          ['@function.method'] = { fg = colors.blue },
          ['@function.method.call'] = { fg = colors.blue },
          ['@method'] = { fg = colors.blue },
          ['@method.call'] = { fg = colors.blue },
          ['@constructor'] = { fg = colors.sapphire },

          ['@keyword'] = { fg = colors.mauve },
          ['@keyword.coroutine'] = { fg = colors.mauve },
          ['@keyword.function'] = { fg = colors.mauve },
          ['@keyword.operator'] = { fg = colors.mauve },
          ['@keyword.import'] = { fg = colors.mauve },
          ['@keyword.storage'] = { fg = colors.mauve },
          ['@keyword.repeat'] = { fg = colors.mauve },
          ['@keyword.return'] = { fg = colors.mauve },
          ['@keyword.exception'] = { fg = colors.mauve },
          ['@keyword.conditional'] = { fg = colors.mauve },
          ['@conditional'] = { fg = colors.mauve },
          ['@repeat'] = { fg = colors.mauve },
          ['@exception'] = { fg = colors.mauve },
          ['@include'] = { fg = colors.mauve },

          ['@type'] = { fg = colors.yellow },
          ['@type.builtin'] = { fg = colors.yellow },
          ['@type.definition'] = { fg = colors.yellow },
          ['@type.qualifier'] = { fg = colors.mauve },

          ['@string'] = { fg = colors.green },
          ['@string.documentation'] = { fg = colors.green },
          ['@string.regexp'] = { fg = colors.peach },
          ['@string.escape'] = { fg = colors.pink },
          ['@string.special'] = { fg = colors.pink },
          ['@string.special.symbol'] = { fg = colors.flamingo },
          ['@string.special.url'] = { fg = colors.blue, underline = true },
          ['@character'] = { fg = colors.teal },
          ['@character.special'] = { fg = colors.pink },

          ['@number'] = { fg = colors.peach },
          ['@number.float'] = { fg = colors.peach },
          ['@float'] = { fg = colors.peach },
          ['@boolean'] = { fg = colors.peach },

          ['@constant'] = { fg = colors.peach },
          ['@constant.builtin'] = { fg = colors.peach },
          ['@constant.macro'] = { fg = colors.mauve },

          ['@variable'] = { fg = colors.text },
          ['@variable.builtin'] = { fg = colors.red },
          ['@variable.parameter'] = { fg = colors.maroon },
          ['@variable.member'] = { fg = colors.lavender },
          ['@parameter'] = { fg = colors.maroon },

          ['@property'] = { fg = colors.lavender },
          ['@field'] = { fg = colors.lavender },

          ['@operator'] = { fg = colors.sky },

          ['@punctuation.bracket'] = { fg = colors.overlay2 },
          ['@punctuation.delimiter'] = { fg = colors.overlay2 },
          ['@punctuation.special'] = { fg = colors.sky },

          ['@comment'] = { fg = colors.overlay0 },
          ['@comment.documentation'] = { fg = colors.overlay0 },
          ['@comment.error'] = { fg = colors.red },
          ['@comment.warning'] = { fg = colors.yellow },
          ['@comment.note'] = { fg = colors.blue },
          ['@comment.todo'] = { fg = colors.yellow },

          ['@tag'] = { fg = colors.red },
          ['@tag.builtin'] = { fg = colors.red },
          ['@tag.attribute'] = { fg = colors.yellow },
          ['@tag.delimiter'] = { fg = colors.sky },

          ['@module'] = { fg = colors.blue },
          ['@namespace'] = { fg = colors.blue },
          ['@label'] = { fg = colors.sapphire },

          ['@attribute'] = { fg = colors.blue },
          ['@attribute.builtin'] = { fg = colors.blue },

          ['@symbol'] = { fg = colors.flamingo },
          ['@markup.heading'] = { fg = colors.blue, bold = true },
          ['@markup.link'] = { fg = colors.blue },
          ['@markup.link.url'] = { fg = colors.blue, underline = true },
          ['@markup.list'] = { fg = colors.mauve },
          ['@markup.raw'] = { fg = colors.teal },
          ['@markup.strong'] = { fg = colors.text, bold = true },
          ['@markup.emphasis'] = { fg = colors.text },
          ['@markup.strikethrough'] = { fg = colors.overlay0, strikethrough = true },

          ['@diff.plus'] = { fg = colors.green },
          ['@diff.minus'] = { fg = colors.red },
          ['@diff.delta'] = { fg = colors.blue },

          Todo = { fg = colors.base, bg = colors.yellow, bold = true },
          Error = { fg = colors.red },
          WarningMsg = { fg = colors.yellow },
        }
      end,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = '',
        },
        telescope = {
          enabled = true,
        },
        which_key = true,
        mason = true,
        noice = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = {},
            hints = {},
            warnings = {},
            information = {},
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
          inlay_hints = {
            background = true,
          },
        },
        alpha = true,
        indent_blankline = {
          enabled = true,
          scope_color = '',
          colored_indent_levels = false,
        },
        lsp_trouble = true,
        neotree = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'f-person/auto-dark-mode.nvim',
    lazy = false,
    opts = {
      set_dark_mode = function()
        vim.opt.background = 'dark'
        vim.cmd.colorscheme('catppuccin-frappe')
      end,
      set_light_mode = function()
        vim.opt.background = 'light'
        vim.cmd.colorscheme('catppuccin-latte')
      end,
      update_interval = 10000,
      fallback = 'dark',
    },
  },
}
