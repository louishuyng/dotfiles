local neogit = require('neogit')

vim.keymap.set('n', ',gb', ':Gitsigns blame<CR>', { silent = true, desc = 'Open blame UI' })

-- vim.keymap.set('n', '<leader>gd', ':Gvdiff ')

vim.keymap.set('n', '<leader>dvf', ':DiffviewFileHistory %<CR>', { desc = 'Track git diff on current file' })
vim.keymap.set('n', '<leader>dva', ':DiffviewFileHistory <CR>', { desc = 'Track git diff on current project' })
vim.keymap.set('n', '<leader>dvo', ':DiffviewOpen<CR>', { desc = 'Open git diff' })
vim.keymap.set('n', '<leader>dvc', ':DiffviewClose<CR>', { desc = 'Close git diff' })

-- Normal mode: history for current line
vim.keymap.set('n', '<leader>dvl', function()
  local line = vim.fn.line('.')
  vim.cmd(string.format('%d,%dDiffviewFileHistory %%', line, line))
end, { desc = 'Git line history' })

-- Visual mode: history for selected lines
vim.keymap.set('v', '<leader>dvl', function()
  local line1 = vim.fn.line('v')
  local line2 = vim.fn.line('.')
  local start = math.min(line1, line2)
  local finish = math.max(line1, line2)
  vim.cmd(string.format('%d,%dDiffviewFileHistory %%', start, finish))
end, { desc = 'Git line history (selection)' })

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
