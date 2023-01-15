return {
  {
    'sainnhe/edge',
    priority = 1000 -- Ensure it loads first

  }, {'DaikyXendo/nvim-material-icon'}, {'kyazdani42/nvim-web-devicons'},
  {"voldikss/vim-floaterm"},
  {'goolord/alpha-nvim', config = function() require('config.libs.alpha') end},
  {'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async'}, -- make fold look modern
  {'rcarriga/nvim-notify'}, -- Statusline
  {'famiu/feline.nvim'}, {'SmiteshP/nvim-navic'}
}
