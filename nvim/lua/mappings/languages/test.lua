local opt = {silent = true}

vim.keymap.set("n", "<leader>ns", ":lua require('neotest').run.run()<CR>", opt)
vim.keymap.set("n", "<leader>nt",
               ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", opt)
vim.keymap.set("n", "<leader>nl", ":lua require('neotest').run.run_last()<CR>",
               opt)

vim.keymap.set("n", ",t", ":TestFile<CR>")
vim.keymap.set("n", ",s", ":TestNearest<CR>")
vim.keymap.set("n", ",l", ":TestLast<CR>")
vim.keymap.set("n", ",a", ":TestSuite<CR>")
