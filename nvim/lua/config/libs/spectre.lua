local flavour = vim.g.theme == 'night' and vim.g.default_dark_catppuccin_theme or 'latte'
local theme = require('catppuccin.palettes').get_palette(flavour)

vim.api.nvim_set_hl(0, 'SpectreSearch', { bg = theme.red, fg = theme.base })
vim.api.nvim_set_hl(0, 'SpectreReplace', { bg = theme.green, fg = theme.base })

require('spectre').setup({
  highlight = {
    replace = 'SpectreReplace',
  },
  mapping = {
    ['send_to_qf'] = {
      map = '<C-q>',
      desc = 'send all items to quickfix',
    },
  },
})

vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
  desc = 'Toggle Spectre',
})
