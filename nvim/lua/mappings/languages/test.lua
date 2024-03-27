local opt = { silent = true }

vim.keymap.set("n", "<space>tf", ":TestFile<CR>")
vim.keymap.set("n", "<space>ts", ":TestNearest<CR>")
vim.keymap.set("n", "<space>tl", ":TestLast<CR>")
vim.keymap.set("n", "<space>ta", ":TestSuite<CR>")
