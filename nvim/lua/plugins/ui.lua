return {
  {
    'navarasu/onedark.nvim',
    priority = 1000 -- Ensure it loads first
  }, {'yamatsum/nvim-nonicons', dependencies = 'kyazdani42/nvim-web-devicons'},
  {'akinsho/bufferline.nvim'}, {"akinsho/toggleterm.nvim"},
  {'goolord/alpha-nvim', config = function() require('config.libs.alpha') end},
  {'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async'}, -- make fold look modern
  {'rcarriga/nvim-notify'}, -- Statusline
  {'famiu/feline.nvim'}, {'SmiteshP/nvim-navic'}
}
