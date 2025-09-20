return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    lazy = false,
    event = 'InsertEnter',
    build = ':Copilot auth',
    opts = {
      -- I don't find the panel useful.
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        -- Use alt to interact with Copilot.
        keymap = {
          -- Disable the built-in mapping, we'll configure it in nvim-cmp.
          accept = '<Bslash><Bslash>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<M-x>',
        },
      },
      copilot_node_command = vim.fn.expand('$HOME') .. '/.asdf/shims/node',
      filetpyes = {
        go = false,
        ['.'] = true,
      },
    },
    config = function(_, opts)
      require('copilot').setup(opts)
      Snacks.toggle({
        name = 'Github Copilot',
        get = function()
          if not vim.g.copilot_enabled then -- HACK: since it's disabled by default the below will throw error
            return false
          end
          return not require('copilot.client').is_disabled()
        end,
        set = function(state)
          if state then
            -- If golang lang then notify it disabled always
            if vim.bo.filetype == 'go' then
              vim.notify('Copilot is disabled for Go files', 'warn', {
                opts = function(notify)
                  notify.icon = '' -- Copilot icon
                end,
              })
              return
            end

            require('copilot').setup(opts) -- setting up for the very first time
            require('copilot.command').enable()

            vim.g.copilot_enabled = true
          else
            require('copilot.command').disable()
            vim.g.copilot_enabled = false
          end
        end,
      }):map('<leader>A')
    end,
  },
}
