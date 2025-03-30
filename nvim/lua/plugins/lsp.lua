return {
  { 'neovim/nvim-lspconfig',      config = function() require "config.lsp" end },
  { 'nvimtools/none-ls.nvim' },
  { 'williamboman/mason.nvim' },
  { 'jay-babu/mason-null-ls.nvim' },
  { 'vim-test/vim-test' },
  {
    'sontungexpt/better-diagnostic-virtual-text',
    lazy = true,
  }
}
