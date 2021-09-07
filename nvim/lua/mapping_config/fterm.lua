local map = require('utils.map').map

local opts = {silent = true}

map('n', '<space>t', ':FloatermToggle<CR>', opts)
map('t', '<space>t', '<C-\\><C-n>:FloatermToggle<CR>', opts)

map('n', '<space>n', ':FloatermNew<CR>', opts)
map('t', '<space>n', '<C-\\><C-n>:FloatermNew<CR>', opts)

map('t', '<Tab>', '<C-\\><C-n>:FloatermNext<CR>', opts)
map('t', '<S-Tab>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

map('n', '<space>ra', ':FloatermNew ranger<CR>', opts)
