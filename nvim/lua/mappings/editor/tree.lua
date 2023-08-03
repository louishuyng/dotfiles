local os_extend = require 'utils.os_extend'
local api = require("nvim-tree.api")

vim.keymap.set("n", "<c-\\>", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", ",nf", ":NvimTreeFocus<CR>", { silent = true })

local top_level = os_extend.capture('git rev-parse --show-toplevel')

vim.keymap.set('n', ",cr",
  ":lua require('nvim-tree.api').tree.change_root('" .. top_level ..
  "')<CR>", { silent = true, noremap = true })
vim.keymap.set('n', ",cd",
  ":lua require('nvim-tree.api').tree.change_root(vim.fn.expand('%:p:h'))<CR>",
  { silent = true, noremap = true })
