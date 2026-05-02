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

--  Alternative Buffer
vim.keymap.set('n', '<BS>', ':b#<CR>', {
  desc = 'Switch between recent buffer',
})

-- Close buffer
vim.keymap.set('n', ',bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer (preserve layout)' })

vim.keymap.set('n', ',bo', function()
  Snacks.bufdelete.other()
end, { desc = 'Delete Other Buffers' })

-- vim.keymap.set('n', ',bd', ':bdelete<CR>', {
--   desc = 'Delete Buffer',
-- })
--
-- vim.keymap.set('n', ',bD', ':w! <bar> %bd <bar> e# <bar> bd# <CR>', {
--   desc = 'Close all buffers',
-- })
