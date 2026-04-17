local opts = { silent = true, remap = true }

vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)', opts)
vim.keymap.set('n', '<leader>ci', '<Plug>(git-conflict-theirs)', opts)
vim.keymap.set('n', '<leader>ch', '<Plug>(git-conflict-ours)', opts)
vim.keymap.set('n', '<leader>cn', '<Plug>(git-conflict-none)', opts)

vim.keymap.set('n', '<leader>co', '<Cmd>GitConflictListQf<CR>', { silent = true })
