vim.keymap.set('n', '<C-f>f', '<Plug>CtrlSFPrompt', {
  noremap = false,
  silent = false,
  desc = 'Open find prompt',
})
vim.keymap.set('n', '<C-f>w', '<Plug>CtrlSFCwordPath', {
  noremap = false,
  silent = false,
  desc = 'Open find prompt by word path',
})

-- When in visual mode, use the selected text as the search term
-- Then search for the word under the cursor
vim.keymap.set('v', '<C-f>', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('CtrlSF ' .. word)
end, {
  noremap = false,
  silent = false,
  desc = 'Find visual text',
})

vim.keymap.set('n', '<C-f>t', ':CtrlSFToggle<CR>', {
  noremap = false,
  silent = false,
  desc = 'Toggle find results',
})
