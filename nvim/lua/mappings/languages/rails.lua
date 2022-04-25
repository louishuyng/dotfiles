vim.keymap.set("n", "<leader>ec", ":Econtroller ")
vim.keymap.set("n", "<leader>ee", ":Eenvironment ")
vim.keymap.set("n", "<leader>ej", ":Ejob ")
vim.keymap.set("n", "<leader>em", ":Emodel ")
vim.keymap.set("n", "<leader>ep", ":Epolicy ")
vim.keymap.set("n", "<leader>er", ":Eresource ")
vim.keymap.set("n", "<leader>ed", ":Eschema ")
vim.keymap.set("n", "<leader>ev", ":Eservice ")
vim.keymap.set("n", "<leader>eh", ":Ehelper ")
vim.keymap.set("n", "<leader>es", ":Espec ")
vim.keymap.set("n", "<leader>et", ":Etask ")

vim.keymap.set("n", "<leader>eg", ":Generate ")

vim.cmd("autocmd BufEnter *.rb nnoremap <leader>mu :Rails db:migrate<CR>")
vim.cmd("autocmd BufEnter *.rb nnoremap <leader>md :Rails db:rollback<CR>")
