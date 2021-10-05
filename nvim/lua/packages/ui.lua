packer = require "packer"
local use = packer.use

use 'zeis/vim-kolor'
use {
  "kyazdani42/nvim-web-devicons",
  config = function()
     require "plugins.icons"
  end,
}
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
use 'osyo-manga/vim-anzu'
use 'romainl/vim-cool'
use 'PeterRincker/vim-searchlight'
use 'glepnir/dashboard-nvim'
use 'itchyny/vim-cursorword'
use {
    "andymass/vim-matchup",
    event = "CursorMoved"
}
use "voldikss/vim-floaterm"
