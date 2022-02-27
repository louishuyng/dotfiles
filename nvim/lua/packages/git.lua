local packer = require "packer"
local use = packer.use

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
  'lewis6991/gitsigns.nvim',
  requires = {
    'nvim-lua/plenary.nvim'
  },
}
use {
  'ruifm/gitlinker.nvim',
  requires = 'nvim-lua/plenary.nvim',
}
use 'tveskag/nvim-blame-line'

use {
  'pwntester/octo.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'kyazdani42/nvim-web-devicons',
  },
}
