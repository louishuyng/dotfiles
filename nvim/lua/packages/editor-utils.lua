local use = packer.use

use {
  "windwp/nvim-autopairs",
  after="nvim-cmp",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-autopairs").setup()
    require("nvim-autopairs.completion.cmp").setup({
      map_cr = true, --  map <CR> on insert mode
      map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
      auto_select = true, -- automatically select the first item
      insert = false, -- use insert confirm behavior instead of replace
      map_char = { -- modifies the function or method delimiter by filetypes
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
use {
  "Pocco81/TrueZen.nvim",
  cmd = {"TZAtaraxis", "TZMinimalist", "TZFocus"},
  config = function()
    require "plugins.zenmode"
  end
}
use 'machakann/vim-swap'
use 'tpope/vim-eunuch'
use 'simnalamburt/vim-mundo'
use 'justinmk/vim-sneak'
use 'matze/vim-move'
use 'brooth/far.vim'
use 'terryma/vim-multiple-cursors'
use 'tpope/vim-surround'
use 'chrisbra/NrrwRgn'
use {
  'windwp/nvim-ts-autotag',
  after = "nvim-treesitter",
}
use 'winston0410/cmd-parser.nvim'
use 'winston0410/range-highlight.nvim'
use { 
  "danymat/neogen", 
  config = function()
    require('neogen').setup {
      enabled = true
    }
  end,
  after = "nvim-treesitter",
}
use 'chaoren/vim-wordmotion'
use 'kamykn/spelunker.vim'
use 'karb94/neoscroll.nvim'
use 'sbdchd/neoformat'
