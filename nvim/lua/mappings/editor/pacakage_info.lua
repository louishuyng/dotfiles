local opt = {silent = true}

vim.keymap
    .set("n", "<leader>ns", ":lua require('package-info').show()<CR>", opt)
vim.keymap
    .set("n", "<leader>nh", ":lua require('package-info').hide()<CR>", opt)
vim.keymap.set("n", "<leader>nu", ":lua require('package-info').update()<CR>",
               opt)
vim.keymap.set("n", "<leader>nd", ":lua require('package-info').delete()<CR>",
               opt)
vim.keymap.set("n", "<leader>ni", ":lua require('package-info').install()<CR>",
               opt)
vim.keymap.set("n", "<leader>nri",
               ":lua require('package-info').reinstall()<CR>", opt)
vim.keymap.set("n", "<leader>np",
               ":lua require('package-info').change_version()<CR>", opt)
