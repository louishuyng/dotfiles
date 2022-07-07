local packer = require "packer"
local use = packer.use

use {
  "nvim-telescope/telescope.nvim",
  requires = {{"nvim-telescope/telescope-project.nvim"}},
  cmd = "Telescope",
  config = function() require("config.cores.telescope").config() end
}
use {'kevinhwang91/nvim-bqf', ft = 'qf'}
use "ThePrimeagen/harpoon"
use 'nvim-telescope/telescope-ui-select.nvim'
use {'kyazdani42/nvim-tree.lua', tag = 'nightly'}
use 'junegunn/fzf.vim'
use 'junegunn/fzf'
