local packer = require "packer"
local use = packer.use

use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}
use 'rcarriga/nvim-notify'
use 'vimwiki/vimwiki'
use 'preservim/vimux'

-- Performance
use 'lewis6991/impatient.nvim'
