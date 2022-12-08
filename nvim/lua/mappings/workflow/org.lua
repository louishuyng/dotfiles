local opts = {silent = true}

vim.keymap.set('n', '<leader>oc', ':Neorg gtd capture<CR>', opts)
vim.keymap.set('n', '<leader>ov', ':Neorg gtd views<CR>', opts)
vim.keymap.set('n', '<leader>oe', ':Neorg gtd edit<CR>', opts)

vim.keymap.set('n', '<leader>oww', ':Neorg workspace work<CR>', opts)
vim.keymap.set('n', '<leader>owl', ':Neorg workspace life<CR>', opts)

vim.keymap.set('n', '<leader>oj', ':Neorg journal ')
vim.keymap.set('n', '<leader>ot', ':Neorg journal toc update<CR>')
vim.keymap.set('n', '<leader>op', ':Neorg presenter start<CR>')
