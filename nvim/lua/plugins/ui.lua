return {
  {
    'LazyVim/LazyVim',
    lazy = false,
    priority = 1000,
  },
  { 'folke/snacks.nvim', lazy = false, priority = 1000 },
  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
  -- {
  --   'akinsho/nvim-bufferline.lua',
  --   event = 'VeryLazy',
  -- },
  -- { 'b0o/incline.nvim' },
  {
    'DaikyXendo/nvim-material-icon',
    lazy = false,
    priority = 999,
    config = function()
      require('nvim-web-devicons').setup({
        override = {},
        color_icons = true,
        default = true,
        strict = true,
        override_by_filename = {},
        override_by_extension = {},
      })
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VimEnter',
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
  },
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      require('smart-splits').setup({
        resize_mode = {
          hooks = {
            on_enter = function()
              vim.notify('Entering resize mode...', vim.log.levels.INFO)
            end,
            on_leave = function()
              vim.notify('Exiting resize mode', vim.log.levels.INFO)
            end,
          },
        },
      })
    end,
  },
  -- Color highlighter
  {
    'norcalli/nvim-colorizer.lua',
    event = 'BufReadPre',
    config = function()
      require('colorizer').setup({
        '*',
        css = { css = true },
        scss = { css = true },
      }, {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = 'background',
      })
    end,
  },
}
