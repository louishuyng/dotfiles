return {
  {"neovim/nvim-lspconfig", config = function() require "config.lsp" end},
  {"nvimtools/none-ls.nvim"}, {"tpope/vim-rails"},
  {'windwp/nvim-ts-autotag', dependencies = {"nvim-treesitter"}},
  {"akinsho/flutter-tools.nvim"}, {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    config = function() require "config.cores.treesitter" end
  }, {'nvim-treesitter/nvim-treesitter-context'},
  {'nvim-treesitter/nvim-treesitter-textobjects'}, {'liuchengxu/vista.vim'},
  {"williamboman/mason.nvim"}, {"jay-babu/mason-null-ls.nvim"},
  {"folke/neodev.nvim", opts = {}}
}
