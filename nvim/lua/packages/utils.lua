local packer = require "packer"
local use = packer.use

use {
  "windwp/nvim-autopairs",
  after="nvim-cmp",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
  end
}
use 'numToStr/Comment.nvim'
use 'szw/vim-maximizer'
use 'tpope/vim-eunuch'
use 'justinmk/vim-sneak'
use 'brooth/far.vim'
use 'terryma/vim-multiple-cursors'
use 'tpope/vim-surround'
use 'chrisbra/NrrwRgn'
use {
  'windwp/nvim-ts-autotag',
  after = "nvim-treesitter",
}
use 'chaoren/vim-wordmotion'
use 'kamykn/spelunker.vim'
use 'sbdchd/neoformat'
use 'konfekt/fastfold'
