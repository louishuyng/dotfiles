vim.keymap.set("n", ",mf", ":lua require(\"harpoon.mark\").add_file()<CR>")
vim.keymap.set("n", "<leader>mn", ":lua require(\"harpoon.ui\").nav_next()<CR>")
vim.keymap.set("n", "<leader>mp", ":lua require(\"harpoon.ui\").nav_prev()<CR>")
