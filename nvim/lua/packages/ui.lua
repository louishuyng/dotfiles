local packer = require "packer"
local use = packer.use

use 'tjdevries/colorbuddy.vim'
use 'tjdevries/gruvbuddy.nvim'
use 'j-hui/fidget.nvim' -- LSP Progress UI
use 'kyazdani42/nvim-web-devicons'
use 'tjdevries/express_line.nvim'
use "voldikss/vim-floaterm"
use {'goolord/alpha-nvim', config = function() require("config.libs.alpha") end}
use 'tjdevries/cyclist.vim'
