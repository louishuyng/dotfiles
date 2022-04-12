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
  },
  cmd = "Telescope",
  config = function()
    require("config.cores.telescope").config()
  end
}
use {'kevinhwang91/nvim-bqf', ft = 'qf'}
use {'junegunn/fzf', run = function()
  vim.fn['fzf#install']()
end}
use "ThePrimeagen/harpoon"
