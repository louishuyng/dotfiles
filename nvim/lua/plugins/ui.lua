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
    event = "VeryLazy",
  },
  -- { 'b0o/incline.nvim' },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  { 
    'folke/noice.nvim',
    event = 'VimEnter',
  },
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    opts = {},
  },
}
