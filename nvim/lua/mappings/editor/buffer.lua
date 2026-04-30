-- Tab
vim.keymap.set('n', '<S-t>', ':tabnew<CR>', {
  desc = 'New Tab',
})

vim.keymap.set('n', ',tc', ':tabclose<CR>', {
  desc = 'Close Tab',
})

-- Move to previous/next
vim.keymap.set('n', ',q', ':BufferLineCyclePrev<CR>', {
  desc = 'Prev Buffer',
})
vim.keymap.set('n', ',w', ':BufferLineCycleNext<CR>', { desc = 'Next Buffer' })

-- Close buffer
vim.keymap.set('n', ',bd', ':bdelete<CR>', {
  desc = 'Delete Buffer',
})

vim.keymap.set('n', ',bD', ':w! <bar> %bd <bar> e# <bar> bd# <CR>', {
  desc = 'Close all buffers',
})

--  Alternative Buffer
vim.keymap.set('n', '<BS>', ':b#<CR>', {
  desc = 'Switch between recent buffer',
})
