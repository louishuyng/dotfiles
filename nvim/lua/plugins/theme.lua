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
        mocha = {
          rosewater = '#ffc0b9',
          flamingo = '#f5aba3',
          pink = '#f592d6',
          mauve = '#c0afff',
          red = '#ea746c',
          maroon = '#ff8595',
          peach = '#fa9a6d',
          yellow = '#ffe081',
          green = '#99d783',
          teal = '#47deb4',
          sky = '#00d5ed',
          sapphire = '#00dfce',
          blue = '#00baee',
          lavender = '#abbff3',
          text = '#cccccc',
          subtext1 = '#bbbbbb',
          subtext0 = '#aaaaaa',
          overlay2 = '#999999',
          overlay1 = '#888888',
          overlay0 = '#777777',
          surface2 = '#666666',
          surface1 = '#555555',
          surface0 = '#444444',
          base = '#202020',
          mantle = '#333333',
          crust = '#222222',
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
