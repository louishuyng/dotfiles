return {
  {
    'github/copilot.vim',
    lazy = false,
  },
  {
    'NickvanDyke/opencode.nvim',
    lazy = false,
    config = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = 'snacks',
          snacks = {
            win = {
              keys = {
                term_normal = false, -- Disable default Esc behavior
              },
            },
          },
        },
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = 'Ask opencode…' })
      vim.keymap.set({ 'n', 'x' }, '<leader>ox', function()
        require('opencode').select()
      end, { desc = 'Execute opencode action…' })
      vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
        require('opencode').toggle()
      end, { desc = 'Toggle opencode' })

      vim.keymap.set('x', '<leader>op', function()
        return require('opencode').operator('@this ')
      end, { desc = 'Add range to opencode', expr = true })

      vim.keymap.set('n', '<leader>op', function()
        return require('opencode').operator('@this ') .. '_'
      end, { desc = 'Add line to opencode', expr = true })

      vim.keymap.set('n', '<leader>ob', function()
        require('opencode').ask('@buffer: ', { submit = true })
      end, { desc = 'Ask about this buffer' })

      vim.keymap.set('n', '<[[>', function()
        require('opencode').command('session.half.page.up')
      end, { desc = 'Scroll opencode up' })
      vim.keymap.set('n', '<]]>', function()
        require('opencode').command('session.half.page.down')
      end, { desc = 'Scroll opencode down' })

      -- Allow Esc to work in OpenCode terminal
      vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
        callback = function(ev)
          -- Check if this is a terminal buffer
          if vim.bo[ev.buf].buftype == 'terminal' then
            local bufname = vim.api.nvim_buf_get_name(ev.buf)
            -- Check if it's an opencode terminal
            if bufname:match('opencode') then
              -- In terminal mode, prevent Esc from exiting to normal mode
              vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = ev.buf, nowait = true })
            end
          end
        end,
      })
    end,
  },
}
