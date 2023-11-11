-- Collect all UI related plugins here
return {
  {'sainnhe/edge'}, {'nvim-tree/nvim-web-devicons'}, {'goolord/alpha-nvim'},
  {'rcarriga/nvim-notify'}, {'nvim-lualine/lualine.nvim'}, {
    "folke/noice.nvim",
    opts = {
      cmdline = {view = "cmdline"},
      messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = false, -- default view for messages
        view_error = false, -- view for errors
        view_warn = "notify", -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "virtualtext" -- view for search count messages. Set to `false` to disable
      }
    },
    event = "VeryLazy",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim", -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify"
    }
  }, {"b0o/incline.nvim", event = "BufReadPre", priority = 1200, opts = {}}
}
