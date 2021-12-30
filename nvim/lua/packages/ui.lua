local packer = require "packer"
local use = packer.use

use 'Yagua/nebulous.nvim'
use 'yamatsum/nvim-nonicons'
use "kyazdani42/nvim-web-devicons"
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
  "akinsho/nvim-bufferline.lua",
  config = function()
    require "cores.bufferline"
  end
}
use 'kevinhwang91/nvim-hlslens'
use 'glepnir/dashboard-nvim'
use {
  "andymass/vim-matchup",
  event = "CursorMoved"
}
use "voldikss/vim-floaterm"
