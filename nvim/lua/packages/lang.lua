local packer = require "packer"
local use = packer.use

use {"neovim/nvim-lspconfig", config = function() require "config.lsp" end}
use "jose-elias-alvarez/null-ls.nvim"
use {
  "nvim-treesitter/nvim-treesitter",
  run = ':TSUpdate',
  config = function() require "config.cores.treesitter" end
}
use {
  "folke/trouble.nvim",
  config = function() require "config.libs.trouble" end
}

use "folke/todo-comments.nvim"

-- ROR
use "vim-test/vim-test"
use "tpope/vim-rails"

-- TS
use {'windwp/nvim-ts-autotag', after = "nvim-treesitter"}

-- Flutter
use "akinsho/flutter-tools.nvim"
