-- Collection of plugins for navigating / modifying files
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {"nvim-telescope/telescope-fzf-native.nvim", build = "make"}
    }
  }, {"ThePrimeagen/harpoon"}, {'nvim-tree/nvim-tree.lua', tag = 'nightly'},
  {"folke/trouble.nvim", config = function() require "config.libs.trouble" end},
  {'stevearc/oil.nvim'}, {
    "folke/todo-comments.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {}
  }
}
