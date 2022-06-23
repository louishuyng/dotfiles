local opts = {silent = true}

vim.keymap.set("n", "<S-t>", ":tabnew<CR>", opts)

vim.keymap.set("n", "1<Tab>", "1gt", opts)
vim.keymap.set("n", "2<Tab>", "2gt", opts)
vim.keymap.set("n", "3<Tab>", "3gt", opts)

vim.keymap.set("n", "<A-1>", ":BufferGoto 1<CR>", opts)
vim.keymap.set("n", "<A-2>", ":BufferGoto 2<CR>", opts)
vim.keymap.set("n", "<A-3>", ":BufferGoto 3<CR>", opts)
vim.keymap.set("n", "<A-4>", ":BufferGoto 4<CR>", opts)
vim.keymap.set("n", "<A-5>", ":BufferGoto 5<CR>", opts)
vim.keymap.set("n", "<A-6>", ":BufferGoto 6<CR>", opts)
vim.keymap.set("n", "<A-7>", ":BufferGoto 7<CR>", opts)
vim.keymap.set("n", "<A-8>", ":BufferGoto 8<CR>", opts)
vim.keymap.set("n", "<A-l>", ":BufferLast<CR>", opts)

-- Move to previous/next
vim.keymap.set('n', ',q', ':BufferPrevious<CR>', opts)
vim.keymap.set('n', ',w', ':BufferNext<CR>', opts)

-- Re-order to previous/next
vim.keymap.set('n', ',Q', ':BufferMovePrevious<CR>', opts)
vim.keymap.set('n', ',W', ' :BufferMoveNext<CR>', opts)

-- Close buffer
vim.keymap.set('n', ',bd', ':BufferClose<CR>', opts)

-- Wipeout buffer
vim.keymap.set("n", ",bda", ":BufferCloseAllButCurrent<CR>", opts)
vim.keymap.set("n", ",bdl", ":BufferCloseBuffersLeft<CR>", opts)
vim.keymap.set("n", ",bdr", ":BufferCloseBuffersRight<CR>", opts)

-- Magic buffer-picking mode
vim.keymap.set('n', '<leader>b', ':BufferPick<CR>', opts)

-- Sort automatically by...
vim.keymap.set('n', '<leader>bb', ':BufferOrderByBufferNumber<CR>', opts)
vim.keymap.set('n', '<leader>bd', ':BufferOrderByDirectory<CR>', opts)
vim.keymap.set('n', '<leader>bl', ':BufferOrderByLanguage<CR>', opts)
vim.keymap.set('n', '<leader>bw', ':BufferOrderByWindowNumber<CR>', opts)
