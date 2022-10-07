local packer = require "packer"
local use = packer.use

use {
  "nvim-telescope/telescope.nvim",
  requires = {{"nvim-telescope/telescope-project.nvim"}},
  cmd = "Telescope",
  config = function() require("config.cores.telescope").config() end
}
use {'kevinhwang91/nvim-bqf', ft = 'qf'}
use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
use "ThePrimeagen/harpoon"
use 'nvim-telescope/telescope-ui-select.nvim'
use {'kyazdani42/nvim-tree.lua', tag = 'nightly'}
use {
  "folke/trouble.nvim",
  config = function() require "config.libs.trouble" end
}
use "folke/todo-comments.nvim"
