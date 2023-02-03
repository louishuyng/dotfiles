local opt = {silent = true}

vim.keymap.set("n", "<leader>ns", ":lua require('neotest').run.run()<CR>", opt)
vim.keymap.set("n", "<leader>nt",
               ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", opt)
vim.keymap.set("n", "<leader>nl", ":lua require('neotest').run.run_last()<CR>",
               opt)

vim.keymap.set("n", "<space>tf", ":TestFile<CR>")
vim.keymap.set("n", "<space>ts", ":TestNearest<CR>")
vim.keymap.set("n", "<space>tl", ":TestLast<CR>")
vim.keymap.set("n", "<space>ta", ":TestSuite<CR>")
