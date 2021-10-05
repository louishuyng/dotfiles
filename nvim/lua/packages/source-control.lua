local use = packer.use

use 'airblade/vim-gitgutter'
use 'tveskag/nvim-blame-line'
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
use 'kdheepak/lazygit.nvim'

