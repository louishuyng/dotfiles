-- Tabs
vim.keymap.set('n', '<S-t>', ':tabnew<CR>', { desc = 'New Tab' })
vim.keymap.set('n', ',Q', ':tabprevious<CR>', { desc = 'Prev Tab' })
vim.keymap.set('n', ',W', ':tabnext<CR>', { desc = 'Next Tab' })
vim.keymap.set('n', ',bD', ':tabclose<CR>', { desc = 'Close Tab' })

-- Buffer cycling (native — replaces BufferLineCyclePrev/Next now that
-- nvim-bufferline is gone).
vim.keymap.set('n', ',q', ':bprevious<CR>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ',w', ':bnext<CR>', { desc = 'Next Buffer' })

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
