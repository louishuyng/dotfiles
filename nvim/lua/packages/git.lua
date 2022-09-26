local packer = require "packer"
local use = packer.use

use {
  "tpope/vim-fugitive",
  cmd = {
    "Git", "Gstatus", "Gwrite", "Gcommit", "Gpush", "Gpull", "Gvdiff", "Gdiff",
    "Git blame", "Git mergetool"
  }
}
use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
use 'akinsho/git-conflict.nvim'
