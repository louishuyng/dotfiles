local packer = require "packer"
local use = packer.use

use "glepnir/oceanic-material"
use "kyazdani42/nvim-web-devicons"
use {
  "norcalli/nvim-colorizer.lua",
  event = "BufRead",
  config = function()
    require("config.libs.others").colorizer()
  end
}
use "feline-nvim/feline.nvim"
use {
  'romgrk/barbar.nvim',
  requires = {'kyazdani42/nvim-web-devicons'}
}
use 'kevinhwang91/nvim-hlslens'
use {
  "andymass/vim-matchup",
  event = "CursorMoved"
}
use "voldikss/vim-floaterm"
use {
  'goolord/alpha-nvim',
  requires = { 'kyazdani42/nvim-web-devicons' },
  config = function ()
    require("config.libs.alpha")
  end
}
