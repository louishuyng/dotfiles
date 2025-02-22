-- Collection of plugins for navigating / modifying files
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim",  build = "make" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    }
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", ";a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      harpoon:extend({
        UI_CREATE = function(cx)
          vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-s>", function()
            harpoon.ui:select_menu_item({ split = true })
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-t>", function()
            harpoon.ui:select_menu_item({ tabedit = true })
          end, { buffer = cx.bufnr })
        end,
      })
    end
  },
  { 'nvim-tree/nvim-tree.lua', tag = 'nightly' },
  {
    'folke/flash.nvim',
    event = "VeryLazy",
    opts = { modes = { search = { enabled = false } } },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash"
      }, {
      "S",
      mode = { "n", "o", "x" },
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
      mode = { "n", "o", "x" },
      function()
        -- show labeled treesitter nodes around the search matches
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search"
    }
    }
  },
}
