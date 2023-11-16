return {
  { 'neovim/nvim-lspconfig',      config = function() require "config.lsp" end },
  { 'nvimtools/none-ls.nvim' },
  { 'liuchengxu/vista.vim' },
  { 'williamboman/mason.nvim' },
  { 'jay-babu/mason-null-ls.nvim' },
  { 'vim-test/vim-test' },
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "solid",
        },
        definition = {
          height = 0.7,
          keys = {
            vsplit = 'v',
            split = 's',
            edit = '<CR>',
            close = 'q',
          }
        },
        finder = {
          keys = {
            vsplit = 'v',
            split = 'i',
            toggle_or_open = '<CR>',
            close = 'q'
         }
        }
      })
    end,
  }
}
