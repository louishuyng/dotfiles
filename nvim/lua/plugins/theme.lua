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
        frappe = {
          base = '#0C0D0C',
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
