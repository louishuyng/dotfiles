local packer = require "packer"
local use = packer.use

use "kyazdani42/nvim-web-devicons"
use "NvChad/nvim-base16.lua"
use {
  "norcalli/nvim-colorizer.lua",
  event = "BufRead",
  config = function()
    require("plugins.others").colorizer()
  end
}
use {
 'glepnir/galaxyline.nvim',
  config = function()
    require "cores.statusline"
  end,

}
use {
  'romgrk/barbar.nvim',
  requires = {'kyazdani42/nvim-web-devicons'}
}
use 'kevinhwang91/nvim-hlslens'
use 'glepnir/dashboard-nvim'
use {
  "andymass/vim-matchup",
  event = "CursorMoved"
}
use "voldikss/vim-floaterm"
