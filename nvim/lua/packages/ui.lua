local packer = require "packer"
local use = packer.use

use 'sainnhe/edge'
use 'kyazdani42/nvim-web-devicons'
use "voldikss/vim-floaterm"
use {'goolord/alpha-nvim', config = function() require("config.libs.alpha") end}
use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'} -- make fold look modern
use 'rcarriga/nvim-notify'

-- Statusline
use "rebelot/heirline.nvim"

-- winbar statusline
use "SmiteshP/nvim-navic"
