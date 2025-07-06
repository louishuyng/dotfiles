local opts = { silent = true }

vim.keymap.set('n', '<leader>cb', ':GitConflictChooseBoth<CR>', opts)
vim.keymap.set('n', '<leader>ci', ':GitConflictChooseTheirs<CR>', opts)
vim.keymap.set('n', '<leader>ch', ':GitConflictChooseOurs<CR>', opts)
vim.keymap.set('n', '<leader>cn', ':GitConflictChooseNone<CR>', opts)

vim.keymap.set('n', '<leader>co', ':GitConflictListQf<CR>', opts)
