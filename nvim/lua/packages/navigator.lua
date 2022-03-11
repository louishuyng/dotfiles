local packer = require "packer"
local use = packer.use

use {
  "ms-jpq/chadtree",
  run = "python3 -m chadtree deps"
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
