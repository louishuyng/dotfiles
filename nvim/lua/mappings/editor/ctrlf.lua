local opts = { noremap = false, silent = false }

vim.keymap.set('n', '<C-f>f', '<Plug>CtrlSFPrompt', opts)
vim.keymap.set('n', '<C-f>w', '<Plug>CtrlSFCwordPath', opts)

-- When in visual mode, use the selected text as the search term
-- Then search for the word under the cursor
vim.keymap.set('v', '<C-f>', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('CtrlSF ' .. word)
end, opts)

vim.keymap.set('n', '<C-f>t', ':CtrlSFToggle<CR>', opts)
