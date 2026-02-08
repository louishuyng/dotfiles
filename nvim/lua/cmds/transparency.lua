-- Transparency commands
local transparency = require('utils.transparency')

-- Toggle transparency
vim.api.nvim_create_user_command('TransparencyToggle', function()
  transparency.toggle()
end, { desc = 'Toggle background transparency' })

-- Enable transparency
vim.api.nvim_create_user_command('TransparencyEnable', function()
  transparency.enable()
end, { desc = 'Enable background transparency' })

-- Disable transparency
vim.api.nvim_create_user_command('TransparencyDisable', function()
  transparency.disable()
end, { desc = 'Disable background transparency' })

vim.keymap.set(
  'n',
  '<leader>0',
  ':TransparencyToggle<CR>',
  { noremap = true, silent = true, desc = 'Toggle Transparency' }
)
