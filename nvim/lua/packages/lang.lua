local packer = require "packer"
local use = packer.use

use {
  'dense-analysis/ale',
  config = function()
    require "cores.ale"
  end
}
use { 
  'nvim-treesitter/nvim-treesitter', 
  run = ':TSUpdate', 
  config = function()
      require "cores.treesitter"
  end
}
use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require "plugins.trouble"
  end
}
use 'vim-test/vim-test'
