return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      require 'config.lsp'
    end,
  },
  { 'williamboman/mason.nvim' },
  { 'stevearc/conform.nvim' },
  {
    'stevearc/aerial.nvim',
    opts = {},
  },
}
