local opts = {noremap = true, silent = true}

vim.keymap.set('n', '<leader>dt', require('dapui').toggle, opts)
vim.keymap.set('n', '<leader>db', ":DapToggleBreakpoint<CR>", opts)
vim.keymap.set('n', '<leader>dc', ":DapContinue<CR>", opts)
vim.keymap.set('n', '<leader>dl', ":DapStepOver<CR>", opts)
vim.keymap.set('n', '<leader>dj', ":DapStepInto<CR>", opts)
vim.keymap.set('n', '<leader>dk', ":DapStepOut<CR>", opts)
vim.keymap.set('n', '<leader>de', ":DapTerminate<CR>")
vim.keymap.set('n', '<leader>dr',
               ":lua require('dapui').open({reset = true})<CR>")
