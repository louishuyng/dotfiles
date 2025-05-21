return {
  { 'olimorris/codecompanion.nvim' },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      -- I don't find the panel useful.
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        -- Use alt to interact with Copilot.
        keymap = {
          -- Disable the built-in mapping, we'll configure it in nvim-cmp.
          accept = '<Bslash><Bslash>',
          next = '<C-n>',
          prev = '<C-p>',
          dismiss = '/',
        },
      },
      filetypes = { markdown = true },
      copilot_node_command = vim.fn.expand('$HOME') .. '/.asdf/shims/node',
    },
    config = function(_, opts)
      local copilot = require 'copilot.suggestion'

      require('copilot').setup(opts)
    end,
  },
}
