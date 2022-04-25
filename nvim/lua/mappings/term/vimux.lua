local opt = {silent = true}

vim.keymap.set("n", ",vp", ":VimuxPromptCommand<CR>", opt)
vim.keymap.set("n", ",vd", ":VimuxCloseRunner<CR>", opt)
vim.keymap.set("n", ",vc", ":VimuxInterruptRunner<CR>", opt)
vim.keymap.set("n", ",vl", ":VimuxRunLastCommand<CR>", opt)
