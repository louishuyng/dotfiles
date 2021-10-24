local packer = require "packer"
local use = packer.use

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
