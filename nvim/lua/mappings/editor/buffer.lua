local map = vim.api.nvim_set_keymap

-- Tab
map('n', '<S-t>', ':tabnew<CR>', {
  noremap = true,
  silent = true,
  desc = 'New Tab',
})

map('n', ',bd', ':tabclose<CR>', {
  noremap = true,
  silent = true,
  desc = 'Close Tab',
})

-- Move to previous/next
map('n', ',q', ':BufferLineCyclePrev<CR>', {
  noremap = true,
  silent = true,
  desc = 'Prev Buffer',
})
map('n', ',w', ':BufferLineCycleNext<CR>', { noremap = true, silent = true, desc = 'Next Buffer' })

-- Close buffer
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
