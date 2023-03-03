return {
  {
    'jeffkreeftmeijer/vim-dim',
    priority = 1000 -- Ensure it loads first
  }, {'kyazdani42/nvim-web-devicons'}, {'akinsho/bufferline.nvim'},
  {"akinsho/toggleterm.nvim"},
  {'goolord/alpha-nvim', config = function() require('config.libs.alpha') end},
  {'rcarriga/nvim-notify'}, -- Statusline
  {'famiu/feline.nvim'}, {'SmiteshP/nvim-navic'}
}
