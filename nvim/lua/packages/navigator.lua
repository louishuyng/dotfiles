local packer = require "packer"
local use = packer.use

use {
  "ms-jpq/chadtree",
  branch = 'chad',
  run = "python3 -m chadtree deps"
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
