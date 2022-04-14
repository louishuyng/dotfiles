local packer = require "packer"
local use = packer.use

use {
  "windwp/nvim-autopairs",
  after="nvim-cmp",
  config = function()
    local present1, autopairs = pcall(require, "nvim-autopairs")
    local present2, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")

    if not (present1 or present2) then
      return
    end

    autopairs.setup()

    local cmp = require "cmp"
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
}
use 'numToStr/Comment.nvim'
use 'folke/zen-mode.nvim'
use 'tpope/vim-eunuch'
use 'justinmk/vim-sneak'
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
use 'gelguy/wilder.nvim'
use({
  'vuki656/package-info.nvim',
  requires = 'MunifTanjim/nui.nvim',
})
use 'numToStr/Navigator.nvim'
