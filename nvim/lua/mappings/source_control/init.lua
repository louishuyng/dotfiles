local neogit = require('neogit')

vim.keymap.set('n', ',gb', ':Gitsigns blame<CR>', { silent = true, desc = 'Open blame UI' })

-- vim.keymap.set('n', '<leader>gd', ':Gvdiff ')

vim.keymap.set('n', '<leader>dvf', ':DiffviewFileHistory %<CR>', { desc = 'Track git diff on current file' })
vim.keymap.set('n', '<leader>dva', ':DiffviewFileHistory <CR>', { desc = 'Track git diff on current project' })
vim.keymap.set('n', '<leader>dvo', ':DiffviewOpen<CR>', { desc = 'Open git diff' })
vim.keymap.set('n', '<leader>dvc', ':DiffviewClose<CR>', { desc = 'Close git diff' })

vim.keymap.set('n', ',gs', function()
  neogit.open()
end, { silent = true, desc = 'Open neo git' })

vim.keymap.set(
  'n',
  '<leader>1',
  ':silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/open_source <CR><CR>',
  { desc = 'Use open_source ssh key' }
)

require 'mappings.source_control.conflict'
require 'mappings.source_control.telescope_git'
