local packer = require "packer"
local use = packer.use

use {
  "windwp/nvim-autopairs",
  after = "nvim-cmp",
  config = function()
    local present1, autopairs = pcall(require, "nvim-autopairs")
    local present2, cmp_autopairs = pcall(require,
                                          "nvim-autopairs.completion.cmp")

    if not (present1 or present2) then return end

    autopairs.setup()

    local cmp = require "cmp"
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
}
use 'numToStr/Comment.nvim'
use 'tpope/vim-eunuch'
use 'justinmk/vim-sneak'
use 'terryma/vim-multiple-cursors'
use 'tpope/vim-surround'
use 'chrisbra/NrrwRgn'
use {"andymass/vim-matchup", event = "CursorMoved"}
use 'preservim/vimux'
use({
  "iamcco/markdown-preview.nvim",
  run = function() vim.fn["mkdp#util#install"]() end
})
use {
  "folke/which-key.nvim",
  config = function() require("which-key").setup {} end
}
use {'nvim-orgmode/orgmode'}
