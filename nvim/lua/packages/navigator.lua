local packer = require "packer"
local use = packer.use

use {
  "kyazdani42/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  config = function()
    require "config.cores.nvimtree"
  end
}
use {
  "nvim-telescope/telescope.nvim",
  requires = {
    {"nvim-lua/plenary.nvim"},
    {"nvim-telescope/telescope-project.nvim"},
    {"nvim-telescope/telescope-fzy-native.nvim"}
  },
  cmd = "Telescope",
  config = function()
    require("config.cores.telescope").config()
  end
}
