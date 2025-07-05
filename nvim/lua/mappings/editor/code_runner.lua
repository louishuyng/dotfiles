local opt = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>rc', ':RunCode<CR>', opt, { desc = 'Run Code' })
vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', opt, { desc = 'Run File' })

vim.keymap.set('n', '<leader>rl', ':VimuxRunLastCommand<CR>', opt, { desc = 'Run Last Command' })
vim.keymap.set('n', '<leader>ri', ':VimuxInterruptRunner<CR>', opt, { desc = 'Interrupt Runner' })
vim.keymap.set('n', '<leader>rp', ':VimuxPromptCommand<CR>', opt, { desc = 'Prompt Command' })
