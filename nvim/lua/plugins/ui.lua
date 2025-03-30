return {
  {
    "LazyVim/LazyVim",
  },
  { "folke/snacks.nvim" },
  { 'romgrk/barbar.nvim' },
  {
    "echasnovski/mini.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end
  },
  { "folke/noice.nvim" },
  {
    "nvim-lualine/lualine.nvim",
    opts = {}
  },
}
