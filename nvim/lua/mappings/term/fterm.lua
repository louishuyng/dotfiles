local opts = {silent = true}

vim.keymap.set('n', '<F12>', ':FloatermToggle<CR>', opts)
vim.keymap.set('t', '<F12>', '<C-\\><C-n>:FloatermToggle<CR>', opts)

vim.keymap.set('t', '<F7>', '<C-\\><C-n>:FloatermNew<CR>', opts)

vim.keymap.set('t', '<Tab>', '<C-\\><C-n>:FloatermNext<CR>', opts)
vim.keymap.set('t', '<S-Tab>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

vim.keymap.set('n', '<leader>nnn', ':FloatermNew nnn<CR>', opts)
vim.keymap.set('n', '<leader>ht', ':FloatermNew bpytop<CR>', opts)
vim.keymap.set('n', '<leader>ld', ':FloatermNew lazydocker<CR>', opts)
