local packer = require "packer"
local use = packer.use

use 'airblade/vim-gitgutter'
use 'rhysd/git-messenger.vim'
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
  }
}
use {
  'ruifm/gitlinker.nvim',
  requires = 'nvim-lua/plenary.nvim',
}
use 'tveskag/nvim-blame-line'
