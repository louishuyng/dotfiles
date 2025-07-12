vim.keymap.set('n', '<leader>qo', ':copen<CR>', opt, { desc = 'Open quick fix', silent = true })
vim.keymap.set('n', '<leader>qd', '<cmd>call setqflist([])<CR>:cclose<CR>', { desc = 'Clear quick fix', silent = true })
