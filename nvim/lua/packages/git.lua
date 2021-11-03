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
    "Git blame",
    "Gvdiff",
    "GBrowse",
  }
}
use 'AndrewRadev/diffurcate.vim'
