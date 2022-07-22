local packer = require "packer"
local use = packer.use

use 'joshdick/onedark.vim'
use 'kyazdani42/nvim-web-devicons'
use "feline-nvim/feline.nvim"
use "voldikss/vim-floaterm"
use {'goolord/alpha-nvim', config = function() require("config.libs.alpha") end}
use 'tjdevries/cyclist.vim'
