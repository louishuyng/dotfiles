-- Collection of plugins for navigating / modifying files
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    dependencies = {
      {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
      "nvim-telescope/telescope-file-browser.nvim",
    }
  },
  {'ThePrimeagen/harpoon'},
  {'nvim-tree/nvim-tree.lua', tag = 'nightly'},
  {'stevearc/oil.nvim'},
  {
    'folke/flash.nvim',
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {modes = {search = {enabled = false}}},
    keys = {
      {
        "s",
        mode = {"n", "x", "o"},
        function() require("flash").jump() end,
        desc = "Flash"
      }, {
        "S",
        mode = {"n", "o", "x"},
        function()
          -- show labeled treesitter nodes around the cursor
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
      }, {
        "r",
        mode = "o",
        function()
          -- jump to a remote location to execute the operator
          require("flash").remote({})
        end,
        desc = "Remote Flash"
      }, {
        "R",
        mode = {"n", "o", "x"},
        function()
          -- show labeled treesitter nodes around the search matches
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search"
      }
    }
  },
}
