local telescope = require('telescope')

vim.keymap.set({ 'n', 'x' }, '<leader>rf', function()
  telescope.extensions.refactoring.refactors()
end)
vim.keymap.set('x', '<leader>re', ':Refactor extract ')
