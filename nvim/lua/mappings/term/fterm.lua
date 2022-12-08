local opts = {silent = true}

vim.keymap.set('n', '<leader>tt', ':FloatermToggle<CR>', opts)
vim.keymap.set('t', '<leader>tt', '<C-\\><C-n>:FloatermToggle<CR>', opts)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', opts)

vim.keymap.set('t', '<F7>', '<C-\\><C-n>:FloatermNew<CR>', opts)

vim.keymap.set('t', '<Tab>', '<C-\\><C-n>:FloatermNext<CR>', opts)
vim.keymap.set('t', '<S-Tab>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

vim.keymap.set('n', '<leader>nnn', ':FloatermNew nnn<CR>', opts)
vim.keymap.set('n', '<leader>ht', ':FloatermNew bpytop<CR>', opts)
vim.keymap.set('n', '<leader>ld', ':FloatermNew lazydocker<CR>', opts)
vim.keymap.set('n', '<leader>lg', ':FloatermNew lazygit<CR>', opts)
vim.keymap.set('n', '<leader>k9', ':FloatermNew k9s<CR>', opts)
