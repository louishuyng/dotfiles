return {
  {'mg979/vim-visual-multi'},
  {'tpope/vim-surround'}, {
    "andymass/vim-matchup",
    init = function() vim.g.matchup_matchparen_offscreen = {method = "popup"} end
  },
  {'preservim/vimux'},
  {'windwp/nvim-spectre'},
  {'mbbill/undotree'},
  {
    "folke/flash.nvim",
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
  {'michaelb/sniprun', build = 'sh install.sh'},
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = {enabled = false, font = "+2"}
      }
    },
    keys = {{"<C-w>o", "<cmd>ZenMode<cr>", desc = "Zen Mode"}}
  },

  -- Rename
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
   -- Terminal
  {'akinsho/toggleterm.nvim', version = "*", config = true},

  -- View code structure
  {'liuchengxu/vista.vim'}, -- Git
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git", "Gstatus", "Gcommit", "Gpush", "Gpull", "Gvdiff", "Gdiff",
      "Git blame", "Git mergetool"
    }
  }, {'lewis6991/gitsigns.nvim', dependencies = {'nvim-lua/plenary.nvim'}},
  {'akinsho/git-conflict.nvim'},
  {'sindrets/diffview.nvim'}
}
