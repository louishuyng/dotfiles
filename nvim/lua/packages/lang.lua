local packer = require "packer"
local use = packer.use

use {
  "neovim/nvim-lspconfig",
  config = function()
    require "lsp"
  end,
}
use "jose-elias-alvarez/nvim-lsp-ts-utils"
use "jose-elias-alvarez/null-ls.nvim"

use {
  "nvim-treesitter/nvim-treesitter",
  run = ':TSUpdate',
  config = function()
      require "cores.treesitter"
  end
}
use {
  "folke/trouble.nvim",
  config = function()
    require "plugins.trouble"
  end
}
use {
  "folke/todo-comments.nvim",
  requires = "nvim-lua/plenary.nvim",
}

-- TAGS
use 'liuchengxu/vista.vim'

-- ROR
use "vim-test/vim-test"
use "puremourning/vimspector"
use "tpope/vim-rails"
