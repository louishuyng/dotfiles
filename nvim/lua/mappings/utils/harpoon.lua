vim.keymap.set("n", ",mf", ":lua require(\"harpoon.mark\").add_file()<CR>")
vim.keymap.set("n", "<leader>mf",
               ":lua require(\"harpoon.ui\").toggle_quick_menu()<CR>")
