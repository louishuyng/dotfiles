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
use 'mg979/vim-visual-multi'
use 'tpope/vim-surround'
use 'chrisbra/NrrwRgn'
use {
  "andymass/vim-matchup",
  setup = function() vim.g.matchup_matchparen_offscreen = {method = "popup"} end
}
use 'preservim/vimux'
use({
  "iamcco/markdown-preview.nvim",
  run = function() vim.fn["mkdp#util#install"]() end
})
use "folke/zen-mode.nvim"
use {'krivahtoo/silicon.nvim', run = './install.sh'}

-- Learning Purpose will remove after finish
use "ThePrimeagen/vim-be-good"
