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
