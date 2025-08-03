return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'config.lsp'
    end,
  },
  { 'williamboman/mason.nvim', cmd = 'Mason', build = ':MasonUpdate' },
  { 'stevearc/conform.nvim', event = { 'BufWritePre' }, cmd = { 'ConformInfo' } },
  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle', 'AerialOpen', 'AerialInfo' },
    opts = {},
  },
}
