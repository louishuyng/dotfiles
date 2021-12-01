local packer = require "packer"
local use = packer.use

-- Analyze and Diagnostic
use {
  'dense-analysis/ale',
  config = function()
    require "cores.ale"
  end
}
use {
  "neovim/nvim-lspconfig",
  config = function()
    require "lsp"
  end,
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

-- ROR
use 'vim-test/vim-test'
use 'puremourning/vimspector'
use 'tpope/vim-rails'
