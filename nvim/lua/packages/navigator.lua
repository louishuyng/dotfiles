local packer = require "packer"
local use = packer.use

use {
  "nvim-neo-tree/neo-tree.nvim",
  requires = 'MunifTanjim/nui.nvim',
  branch = "v2.x",
}
use {
  "nvim-telescope/telescope.nvim",
  requires = {
    {"nvim-telescope/telescope-project.nvim"},
  },
  cmd = "Telescope",
  config = function()
    require("config.cores.telescope").config()
  end
}
use {'kevinhwang91/nvim-bqf', ft = 'qf'}
use "ThePrimeagen/harpoon"
