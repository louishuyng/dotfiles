local use = packer.use

use 'airblade/vim-gitgutter'
use 'f-person/git-blame.nvim'
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
