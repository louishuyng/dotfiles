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
  "neovim/nvim-lspconfig",
  config = function()
    require "lsp"
  end,
}
use {
  "jose-elias-alvarez/null-ls.nvim",
  requires = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require "plugins/null"
  end,
}

use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require "plugins.trouble"
  end
}

-- RAILS --
use 'thoughtbot/vim-rspec'
