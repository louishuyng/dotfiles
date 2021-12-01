local packer = require "packer"
local use = packer.use

use {
  "kyazdani42/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  config = function()
    require "cores.nvimtree"
  end
}
use {
  "nvim-telescope/telescope.nvim",
  requires = {
    {"nvim-lua/plenary.nvim"},
    {"nvim-telescope/telescope-project.nvim"}
  },
  cmd = "Telescope",
  config = function()
    require("cores.telescope").config()
  end
}
