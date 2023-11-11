-- Collect all the Utils Plugins
return {
  {
    "windwp/nvim-autopairs",
    dependencies = {"nvim-cmp"},
    config = function()
      local present1, autopairs = pcall(require, "nvim-autopairs")
      local present2, cmp_autopairs = pcall(require,
                                            "nvim-autopairs.completion.cmp")

      if not (present1 or present2) then return end

      autopairs.setup()

      local cmp = require "cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  }, {'numToStr/Comment.nvim'}, {'mg979/vim-visual-multi'},
  {'tpope/vim-surround'}, {
    "andymass/vim-matchup",
    init = function() vim.g.matchup_matchparen_offscreen = {method = "popup"} end
  }, {'preservim/vimux'},
  {'narutoxy/silicon.lua', config = function() require('silicon').setup({}) end},
  {'windwp/nvim-spectre'}, {'mbbill/undotree'}, -- Flash Nvim
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
  }, {'akinsho/toggleterm.nvim', version = "*", config = true},
  {'kamykn/spelunker.vim'}, {'michaelb/sniprun', build = 'sh install.sh'}, {
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
  }
}
