vim.keymap.set('n', '<c-\\>', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle nvim-tree' })

vim.keymap.set(
  'n',
  ',nf',
  ':NvimTreeFindFile<CR>',
  { silent = true, desc = 'Focus current buffer in tree' }
)

vim.keymap.set('n', ',cr', function()
  local top_level = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or top_level == nil or top_level == '' then return end
  local api = require('nvim-tree.api')
  api.tree.change_root(top_level)
  api.tree.find_file({ open = true, focus = true })
end, { silent = true, noremap = true, desc = 'Reset tree root to project dir' })

vim.keymap.set('n', ',cd', function()
  local current_dir = vim.fn.expand('%:p:h')
  if current_dir == '' then return end
  local api = require('nvim-tree.api')
  api.tree.change_root(current_dir)
  api.tree.find_file({ open = true, focus = true })
end, { silent = true, noremap = true, desc = 'Change tree root to current file dir' })
