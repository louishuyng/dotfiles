local opts = { noremap = false, silent = false }

vim.keymap.set('n', '<C-f>f', '<Plug>CtrlSFPrompt', opts)
vim.keymap.set('n', '<C-f>w', '<Plug>CtrlSFCwordPath', opts)
vim.keymap.set('v', '<C-f>', '<Plug>CtrlSFVwordPath', opts)
