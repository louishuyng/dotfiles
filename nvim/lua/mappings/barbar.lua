local map = require 'utils.map'

local opts = { noremap = true, silent = true }

map("n", "<S-t>", ":tabnew<CR>", opts, {silent = true})

map("n", "1<Tab>", "1gt", opts, {silent = true})
map("n", "2<Tab>", "2gt", opts, {silent = true})
map("n", "3<Tab>", "3gt", opts, {silent = true})

map("n", "<A-1>", ":BufferGoto 1<CR>", opts)
map("n", "<A-2>", ":BufferGoto 2<CR>", opts)
map("n", "<A-3>", ":BufferGoto 3<CR>", opts)
map("n", "<A-4>", ":BufferGoto 4<CR>", opts)
map("n", "<A-5>", ":BufferGoto 5<CR>", opts)
map("n", "<A-6>", ":BufferGoto 6<CR>", opts)
map("n", "<A-7>", ":BufferGoto 7<CR>", opts)
map("n", "<A-8>", ":BufferGoto 8<CR>", opts)
map("n", "<A-l>", ":BufferLast<CR>", opts)

-- Move to previous/next
map('n', ',q', ':BufferPrevious<CR>', opts)
map('n', ',w', ':BufferNext<CR>', opts)

-- Re-order to previous/next
map('n', ',Q', ':BufferMovePrevious<CR>', opts)
map('n', ',W', ' :BufferMoveNext<CR>', opts)

-- Close buffer
map('n', ',bd', ':BufferClose<CR>', opts)

-- Wipeout buffer
map("n", ",bda", ":BufferCloseAllButCurrent<CR>", opts)
map("n", ",bdl", ":BufferCloseBuffersLeft<CR>", opts)
map("n", ",bdr", ":BufferCloseBuffersRight<CR>", opts)

-- Magic buffer-picking mode
map('n', '<leader>b', ':BufferPick<CR>', opts)

-- Sort automatically by...
map('n', '<leader>bb', ':BufferOrderByBufferNumber<CR>', opts)
map('n', '<leader>bd', ':BufferOrderByDirectory<CR>', opts)
map('n', '<leader>bl', ':BufferOrderByLanguage<CR>', opts)
map('n', '<leader>bw', ':BufferOrderByWindowNumber<CR>', opts)
