return {
  { 'mg979/vim-visual-multi' }, -- Multi Cursor
  {
    "andymass/vim-matchup",
    init = function() vim.g.matchup_matchparen_offscreen = { method = "popup" } end
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
  },

  { 'mbbill/undotree' },

  -- Mark
  {
    'chentoast/marks.nvim',
    config = function()
      require('marks').setup({})
    end
  },

  -- Fast jump
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false },
        char = { enabled = false }
      }
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash"
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          -- show labeled treesitter nodes around the cursor
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
      },
      {
        "r",
        mode = "o",
        function()
          -- jump to a remote location to execute the operator
          require("flash").remote({})
        end,
        desc = "Remote Flash"
      },
      {
        "R",
        mode = { "n", "o", "x" },
        function()
          -- show labeled treesitter nodes around the search matches
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search"
      }
    }
  },

  { 'michaelb/sniprun',          build = 'sh install.sh' }, -- Run code

  -- Focus
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" }
      }
    },
    keys = { { "<C-w>o", "<cmd>ZenMode<cr>", desc = "Zen Mode" } }
  },

  -- Git
  { 'tpope/vim-fugitive' },
  { 'lewis6991/gitsigns.nvim',   dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'sindrets/diffview.nvim' },
  { 'akinsho/git-conflict.nvim', version = "*",                             config = true },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
  },

  -- Refactoring
  {
    'ThePrimeagen/refactoring.nvim',
    config = function()
      require('refactoring').setup()
    end
  },

  -- REST API
  {
    "vhyrro/luarocks.nvim",
    opts = {
      rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua", "rest.nvim" }, -- Specify LuaRocks packages to install
    },
    priority = 1000,
    config = true,
  },
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "luarocks.nvim", "j-hui/fidget.nvim" },
  },

  -- AI
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      {
        "stevearc/dressing.nvim", -- Improves the default Neovim UI
        opts = {},
      },
    },
  },

  -- Key map finding
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- Find matching words
  {
    'dyng/ctrlsf.vim'
  },

  -- MINI plugins
  {
    'echasnovski/mini.ai',
    config = function()
      local spec_treesitter = require('mini.ai').gen_spec.treesitter
      require('mini.ai').setup({
        custom_textobjects = {
          f = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
          c = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
          o = spec_treesitter({
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
          })
        }
      })
    end,
  },
  {
    'echasnovski/mini.statusline',
    config = function()
      local statusline = require("mini.statusline")
      statusline.setup({
        use_icons = vim.g.have_nerd_font,
      })
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end

      statusline.section_filename = function()
        -- Short path
        return vim.fn.expand("%:~:.:.")
      end
    end
  },
  {
    'echasnovski/mini.bracketed',
    version = false,
    config = function()
      require('mini.bracketed').setup({})
    end
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('mini.surround').setup({})
    end
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require('mini.pairs').setup({})
    end
  },
}
