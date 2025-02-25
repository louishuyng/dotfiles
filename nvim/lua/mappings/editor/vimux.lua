local opt = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>rl", ":VimuxRunLastCommand<CR>", opt)
vim.keymap.set("n", "<leader>rc", ":VimuxInterruptRunner<CR>", opt)
vim.keymap.set("n", "<leader>ro", ":VimuxPromptCommand<CR>", opt)
