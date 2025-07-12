local os_extend = require 'utils.os_extend'

vim.keymap.set('n', '<c-\\>', ':Neotree toggle<CR>', { silent = true, desc = 'Open neotree' })
vim.keymap.set(
  'n',
  ',nf',
  ':Neotree filesystem reveal<CR>',
  { silent = true, desc = 'Focus current buffer in neo tree' }
)

local top_level = os_extend.capture('git rev-parse --show-toplevel')

-- Change root to the git top-level directory
vim.keymap.set('n', ',cr', function()
  local top_level = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 then
    vim.cmd('Neotree reveal_force_cwd dir=' .. top_level)
  end
end, { silent = true, noremap = true, desc = 'Rest active dir to project dir' })

-- Change root to the current file's directory
vim.keymap.set('n', ',cd', function()
  local current_dir = vim.fn.expand('%:p:h')
  vim.cmd('Neotree reveal_force_cwd dir=' .. current_dir)
end, { silent = true, noremap = true, desc = 'Change active dir to current dir' })
