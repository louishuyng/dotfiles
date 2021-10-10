local use = packer.use

use {
  "kyazdani42/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  config = function()
      require "cores.nvimtree"
  end
}
use {
  "nvim-telescope/telescope.nvim",
  requires = { {"nvim-lua/plenary.nvim"} },
  cmd = "Telescope",
  config = function()
      require("cores.telescope").config()
      require("telescope").load_extension('projects')
  end
}
use {
  "ahmedkhalf/project.nvim",
  config = function()
    require 'plugins.projects_nvim'
  end
}
use {
  'ThePrimeagen/harpoon',
  requires = {
    'nvim-lua/popup.nvim'
  },
  opt = true,
  event = { 'VimEnter' },
  setup = require('plugins.harpoon').setup,
  config = require('plugins.harpoon').config,
}
