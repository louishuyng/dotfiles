return {
  {
    'rktjmp/lush.nvim',
    lazy = false,
    priority = 1001,
  },
  {
    'f-person/auto-dark-mode.nvim',
    lazy = false,
    opts = {
      set_dark_mode = function()
        local reload_theme = require('utils.reload_theme').reload_theme
        vim.g.theme = 'night'
        reload_theme()
      end,
      set_light_mode = function()
        local reload_theme = require('utils.reload_theme').reload_theme
        vim.g.theme = 'light'
        reload_theme()
      end,
      update_interval = 10000,
      fallback = 'dark',
    },
  },
}
