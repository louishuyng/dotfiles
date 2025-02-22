return {
  {
    "LazyVim/LazyVim",
  },
  { "folke/snacks.nvim" },
  {
    "vuki656/package-info.nvim",
  },
  {
    "DaikyXendo/nvim-material-icon",
    lazy = true,
    init = function()
      require 'nvim-web-devicons'.setup {
        color_icons = true,
        default = true,
      }
    end,
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.debug = false
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })

      table.insert(opts.routes, 1, {
        filter = {
          ["not"] = {
            event = "lsp",
            kind = "progress",
          },
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })
      return opts
    end,
  },
  { "SmiteshP/nvim-navic" },
  -- {
  --   'echasnovski/mini.statusline',
  --   config = function()
  --     local statusline = require("mini.statusline")
  --     statusline.setup({
  --       use_icons = vim.g.have_nerd_font,
  --     })
  --     ---@diagnostic disable-next-line: duplicate-set-field
  --     statusline.section_location = function()
  --       return "%2l:%-2v"
  --     end
  --
  --     statusline.section_filename = function()
  --       -- Short path
  --       return vim.fn.expand("%:~:.:.")
  --     end
  --
  --     statusline.section_filetype = function()
  --       return "%#MiniStatuslineModeNormal# " .. vim.bo.filetype
  --     end
  --   end
  -- },
  {
    "nvim-lualine/lualine.nvim",
    opts = {}
  },
}
