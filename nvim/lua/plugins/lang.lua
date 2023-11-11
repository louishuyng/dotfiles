-- Collection of language specific plugins and testing tools
return {
  {"neovim/nvim-lspconfig", config = function() require "config.lsp" end},
  {"nvimtools/none-ls.nvim"}, {"tpope/vim-rails"}, {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    config = function() require "config.cores.treesitter" end
  }, {'nvim-treesitter/nvim-treesitter-textobjects'}, {'liuchengxu/vista.vim'},
  {"williamboman/mason.nvim"}, {"jay-babu/mason-null-ls.nvim"},
  {"vim-test/vim-test"}
}
