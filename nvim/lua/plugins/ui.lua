return {
  {
    'LazyVim/LazyVim',
    lazy = false,
    priority = 1000,
  },
  { 'folke/snacks.nvim', lazy = false, priority = 1000 },
  -- {
  --   'SmiteshP/nvim-navic',
  -- },
  {
    'akinsho/nvim-bufferline.lua',
    event = 'VeryLazy',
  },
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
}
