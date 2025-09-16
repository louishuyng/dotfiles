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
    lazy = true,
    config = function()
      require 'nvim-web-devicons'.setup {
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = '',
            color = '#428850',
            cterm_color = '65',
            name = 'Zsh',
          },
        },
        -- globally enable different highlight colors per icon (default to true)
        -- if set to false all icons will have the default icon's color
        color_icons = true,
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
      }
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
}
