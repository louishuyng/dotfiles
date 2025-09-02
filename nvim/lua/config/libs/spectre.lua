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

vim.keymap.set('n', '<leader>R', '<cmd>lua require("spectre").toggle()<CR>', {
  desc = 'Toggle Spectre',
})
