return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      require 'config.lsp'
    end,
  },
  { 'nvimtools/none-ls.nvim' },
  { 'williamboman/mason.nvim' },
  { 'vim-test/vim-test' },
  { 'stevearc/conform.nvim' },
}
