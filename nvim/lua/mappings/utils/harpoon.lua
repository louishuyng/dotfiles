vim.keymap.set("n", ",mf", ":lua require(\"harpoon.mark\").add_file()<CR>")
vim.keymap.set("n", "<leader>mf", ":Telescope harpoon marks<CR>")
vim.keymap.set("n", "m}", ":lua require(\"harpoon.ui\").nav_next()<CR>")
vim.keymap.set("n", "m{", ":lua require(\"harpoon.ui\").nav_prev()<CR>")
