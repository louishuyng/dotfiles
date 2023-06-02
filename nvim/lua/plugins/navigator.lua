return {
  {"nvim-telescope/telescope.nvim", cmd = "Telescope"},
  {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'}, {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"}
  }, {"ThePrimeagen/harpoon"}, {'kyazdani42/nvim-tree.lua', tag = 'nightly'},
  {"folke/trouble.nvim", config = function() require "config.libs.trouble" end},
  {"folke/todo-comments.nvim"}, {'stevearc/oil.nvim'}
}
