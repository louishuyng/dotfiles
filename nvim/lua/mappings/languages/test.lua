local opts = { silent = true }

vim.keymap.set("n", "<space>tf", ":TestFile<CR>", opts)
vim.keymap.set("n", "<space>ts", ":TestNearest<CR>", opts)
vim.keymap.set("n", "<space>tl", ":TestLast<CR>", opts)
vim.keymap.set("n", "<space>ta", ":TestSuite<CR>", opts)
vim.keymap.set("n", "<space>tc", ":VimuxInterruptRunner<CR>", opts)
vim.keymap.set("n", "<space>tz", ":VimuxZoomRunner<CR>", opts)
