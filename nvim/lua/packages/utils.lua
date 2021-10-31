local packer = require "packer"
local use = packer.use

use {
  "windwp/nvim-autopairs",
  after="nvim-cmp",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-autopairs").setup()
    require("nvim-autopairs.completion.cmp").setup({
      map_cr = true,
      map_complete = true,
      auto_select = true,
      insert = false,
      map_char = {
        all = '(',
        tex = '{'
      }
    })
  end
}
use {
  "terrortylor/nvim-comment",
  cmd = "CommentToggle",
  config = function()
    require("plugins.others").comment()
  end
}
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
