local packer = require "packer"
local use = packer.use

use {
  "neovim/nvim-lspconfig",
  config = function()
    require "config.lsp"
  end,
}
use "jose-elias-alvarez/nvim-lsp-ts-utils"
use "jose-elias-alvarez/null-ls.nvim"
use {
  "nvim-treesitter/nvim-treesitter",
  run = ':TSUpdate',
  config = function()
      require "config.cores.treesitter"
  end
}
use "RRethy/nvim-treesitter-textsubjects"
use {
  "folke/trouble.nvim",
  config = function()
    require "config.libs.trouble"
  end
}
use "folke/todo-comments.nvim"

-- DEBUG
use "puremourning/vimspector"

-- ROR
use "vim-test/vim-test"
use "tpope/vim-rails"

-- Quick runtpope/vim-rails
use "is0n/jaq-nvim"
