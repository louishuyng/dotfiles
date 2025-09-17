local opt = { silent = true, noremap = true }

-- General
vim.keymap.set('n', ',s', ':<C-u>split<CR>', { silent = true, noremap = true, desc = 'V Split buffer' })
vim.keymap.set('n', ',v', ':<C-u>vsplit<CR>', { silent = true, noremap = true, desc = 'H Split buffer' })

vim.keymap.set('v', '<C-x>', ':!pbcopy<CR>', opt)
vim.keymap.set('v', '<C-c>', ':w !pbcopy<CR><CR>', opt)

vim.keymap.set('v', '/', '*')
vim.keymap.set('n', '<C-j>', '<C-w>j', opt)
vim.keymap.set('n', '<C-k>', '<C-w>k', opt)
vim.keymap.set('n', '<C-l>', '<C-w>l', opt)
vim.keymap.set('n', '<C-h>', '<C-w>h', opt)

-- Faster Save and Quit
vim.keymap.set('n', '<leader>w', ':silent w!<CR>', opt)
vim.keymap.set('n', '<leader>W', ':silent wa!<CR>', opt)
vim.keymap.set('n', '<leader>q', ':q!<CR>', opt)

-- Scrolling Center
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", opt)
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", opt)

-- Macro Apply Visual
vim.keymap.set('v', ',m', ':normal @', { desc = 'Apply macro' })

-- Move Block
vim.keymap.set('v', '<S-j>', ":m'>+<CR>gv=gv", opt)
vim.keymap.set('v', '<S-k>', ':m-2<CR>gv=gv', opt)

-- Sorting
vim.keymap.set('v', '<leader>so', ':sort<CR>', { silent = true, noremap = true, desc = 'Sorting' })

-- Open URL
vim.keymap.set(
  'n',
  '<leader>ob',
  ':call OpenUrlUnderCursor()<CR>',
  { silent = true, noremap = true, desc = 'Open url under cursor' }
)

-- Yank
-- " replace currently selected text with default register
-- " without yanking it
vim.keymap.set('v', 'p', '"_dP', opt)

-- Replace
vim.keymap.set('n', ';r', 'yiw:%s/<C-R>"/', opt)
vim.keymap.set('v', ';r', '"_y:%s/<C-R>"/', opt)

-- Lazy
vim.keymap.set('n', '<leader>li', ':Lazy install<CR>', opt)
vim.keymap.set('n', '<leader>lc', ':Lazy clean<CR>', opt)
vim.keymap.set('n', '<leader>lu', ':Lazy update<CR>', opt)

-- Register
local esc = vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
vim.fn.setreg('l', "yoconsole.log('" .. esc .. 'pa:' .. esc .. 'la, ' .. esc .. 'pl')

-- Noice
vim.keymap.set('n', '<leader>mo', ':Noice all<CR>', { desc = 'Log vim messages', silent = true, noremap = true })

-- Reload Buffer
vim.keymap.set('n', '<leader>rb', ':e!<CR>', { desc = 'Reload buffer', silent = true, noremap = true })
