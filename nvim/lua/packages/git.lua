local packer = require "packer"
local use = packer.use

use {
  "tpope/vim-fugitive",
  cmd = {
    "Git",
    "Gstatus",
    "Gwrite",
    "Gcommit",
    "Gpush",
    "Gpull",
    "Gvdiff",
    "Git blame",
    "Git mergetool",
  }
}
use {
  'lewis6991/gitsigns.nvim',
  requires = {
    'nvim-lua/plenary.nvim'
  },
}
use {
  'pwntester/octo.nvim',
  requires = {
    'nvim-telescope/telescope.nvim',
  },
}
use 'akinsho/git-conflict.nvim'
