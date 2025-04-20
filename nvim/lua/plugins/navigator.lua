-- Collection of plugins for navigating / modifying files
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
    },
  },
  {
    'desdic/marlin.nvim',
    opts = {},
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      -- fill any relevant options here
    },
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = { modes = { search = { enabled = false } } },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'o', 'x' },
        function()
          -- show labeled treesitter nodes around the cursor
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          -- jump to a remote location to execute the operator
          require('flash').remote({})
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'n', 'o', 'x' },
        function()
          -- show labeled treesitter nodes around the search matches
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
    },
  },
}
