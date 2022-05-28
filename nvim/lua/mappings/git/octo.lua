
vim.keymap.set("n", "<leader>gpl", ":Octo pr list<CR>")
vim.keymap.set("n", "<leader>gpc", ":Octo pr create<CR>")

vim.keymap.set("n", "<leader>gtr", ":Octo thread resolve<CR>")
vim.keymap.set("n", "<leader>gtR", ":Octo thread unresolve<CR>")

vim.keymap.set("n", "<leader>grv", ":Octo review start<CR>")
vim.keymap.set("n", "<leader>grd", ":Octo review discard<CR>")
vim.keymap.set("n", "<leader>grs", ":Octo review submit<CR>")

-- Merge Tool
vim.keymap.set("n", "<leader>gm", ":GitConflictListQf<CR>")
vim.keymap.set('n', '<leader>ch', '<Plug>(git-conflict-ours)')
vim.keymap.set('n', '<leader>ci', '<Plug>(git-conflict-theirs)')
vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)')
vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)')
vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)")
vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)")
