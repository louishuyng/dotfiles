local use = packer.use

use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}
use {
  'iamcco/markdown-preview.nvim',
  run = function() vim.fn['mkdp#util#install']() end,
  ft = {'markdown'}
}
use 'rcarriga/nvim-notify'
