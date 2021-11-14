local map = require 'utils.map'

local opts = {silent = true}

map('n', '<F12>', ':FloatermToggle<CR>', opts)
map('t', '<F12>', '<C-\\><C-n>:FloatermToggle<CR>', opts)

map('t', '<F7>', '<C-\\><C-n>:FloatermNew<CR>', opts)

map('t', '<Tab>', '<C-\\><C-n>:FloatermNext<CR>', opts)
map('t', '<S-Tab>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

map('n', '<leader>ra', ':FloatermNew ranger<CR>', opts)
map('n', '<leader>rt', ':FloatermNew bpytop<CR>', opts)
