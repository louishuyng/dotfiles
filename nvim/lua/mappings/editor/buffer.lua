local map = vim.api.nvim_set_keymap

-- Tab
map('n', '<S-t>', ':tabnew<CR>', {
  noremap = true,
  silent = true,
  desc = 'New Tab',
})

map('n', '[<Tab>', ':tabprevious<CR>', {
  noremap = true,
  silent = true,
  desc = 'Prev Tab',
})
map('n', ']<Tab>', ':tabnext<CR>', {
  noremap = true,
  silent = true,
  desc = 'Next Tab',
})

-- Move to previous/next
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', {
  noremap = true,
  silent = true,
  desc = 'Next Buffer',
})
map('n', '<A-.>', '<Cmd>BufferNext<CR>', { noremap = true, silent = true, desc = 'Next Buffer' })

-- Re-order to previous/next
map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', {
  noremap = true,
  silent = true,
  desc = 'Move Buffer Previous',
})
map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', {
  noremap = true,
  silent = true,
  desc = 'Move Buffer Next',
})

-- Close buffer
map('n', ',bd', ':bdelete<CR>', {
  noremap = true,
  silent = true,
  desc = 'Close buffer',
})
map('n', ',bda', ':w! <bar> %bd <bar> e# <bar> bd# <CR>', {
  noremap = true,
  silent = true,
  desc = 'Close all buffer',
})

--  Alternative Buffer
map('n', '<BS>', ':b#<CR>', {
  noremap = true,
  silent = true,
  desc = 'Switch between recent buffer',
})
