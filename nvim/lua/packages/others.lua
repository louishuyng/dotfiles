local use = packer.use

use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}
use {
  "Pocco81/AutoSave.nvim",
  config = function()
    require "plugins.autosave"
  end,
  cond = function()
    return vim.g.auto_save == true
  end
}
use {
  'iamcco/markdown-preview.nvim',
  run = function() vim.fn['mkdp#util#install']() end,
  ft = {'markdown'}
}
use {
  'NTBBloodbath/rest.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require("rest-nvim").setup({
      -- Open request results in a horizontal split
      result_split_horizontal = false,
      -- Skip SSL verification, useful for unknown certificates
      skip_ssl_verification = false,
    })
  end
}
