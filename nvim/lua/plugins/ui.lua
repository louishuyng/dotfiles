return {
  {'sainnhe/edge'},
  {'nvim-tree/nvim-web-devicons'},
  {'goolord/alpha-nvim'},
  {'nvim-lualine/lualine.nvim'},

  -- messages, cmdline and the popupmenu
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = {}
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
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })
      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = {enter = true, format = "details"},
          filter = {}
        }
      }
      opts.cmdline = {view = "cmdline"}
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.routes = {
        {
          -- Avoid written messages
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        {
          -- Avoid all messages with kind ""
          filter = {
            event = "msg_show",
            kind = "",
          },
          opts = { skip = true },
        }
      }

      opts.messages = {
        view_error = false
      }

      opts.lsp = {
        progress = {
          enabled = false,
        }
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },

  -- Float file info
  {
    'b0o/incline.nvim',
    event = "BufReadPre",
    priority = 1200,
    opts = {},
    config = function()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = {guibg = "#1E1E1E", guifg = "#A8C888"},
            InclineNormalNC = {guibg = "#1E1E1E"}
          }
        },
        window = {margin = {vertical = 0, horizontal = 1}},
        hide = {cursorline = true},
        render = function(props)
          local filename = vim.fn.fnamemodify(
                               vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(
                                  filename)
          return {{icon, guifg = color}, {" "}, {filename}}
        end
      })
    end
  }
}
