vim.keymap.set('n', ',qo', ':copen<CR>', opt, { desc = 'Open quick fix', silent = true })
vim.keymap.set('n', ',qc', '<cmd>call setqflist([])<CR>:cclose<CR>', { desc = 'Clear quick fix', silent = true })
