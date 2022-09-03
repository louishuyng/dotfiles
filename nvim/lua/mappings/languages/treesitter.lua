-- Extract block doesn't need visual mode
vim.keymap.set("n", "<leader>rb",
               [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
               {noremap = true, silent = true, expr = false})
vim.keymap.set("n", "<leader>rbf",
               [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
               {noremap = true, silent = true, expr = false})

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.keymap.set("n", "<leader>ri",
               [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
               {noremap = true, silent = true, expr = false})

-- remap to open the Telescope refactoring menu in visual mode
vim.keymap.set("v", "<leader>rr",
               "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
               {noremap = true})

vim.keymap.set("n", "<leader>lk", "<Esc><cmd>lua require('tsht').nodes()<CR>",
               {noremap = true})
