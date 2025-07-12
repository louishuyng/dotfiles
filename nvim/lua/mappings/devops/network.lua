vim.keymap.set('n', '<leader>sni', ":lua require('functions.network').show_local_ip()<CR>", { desc = 'Show local ip' })
vim.keymap.set(
  'n',
  '<leader>snI',
  ":lua require('functions.network').show_public_ip()<CR>",
  { desc = 'Show public ip' }
)
