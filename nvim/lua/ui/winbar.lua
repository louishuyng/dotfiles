local utils = require('dropbar.utils')

local M = {}

-- Dropbar automatically manages winbar, no manual setup needed
-- Just configure the appearance and behavior
require('dropbar').setup({
  menu = {
    keymaps = {
      ['h'] = '<C-w>q',
      ['l'] = function()
        local menu = utils.menu.get_current()
        if not menu then
          return
        end
        local cursor = vim.api.nvim_win_get_cursor(menu.win)
        local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
        if component then
          menu:click_on(component, nil, 1, 'l')
        end
      end,
    },
  },
})

return M
