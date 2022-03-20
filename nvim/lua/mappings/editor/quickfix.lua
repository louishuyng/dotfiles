local map = require 'utils.map'

local opt = {}

map("n", "<A-j>", ":cn<CR>", opt, {silent = true})
map("n", "<A-k>", ":cp<CR>", opt, {silent = true})
map("n", "<leader>j", ":lnext<CR>", opt, {silent = true})
map("n", "<leader>k", ":lprev<CR>", opt, {silent = true})

map("n", "<leader>co", ":copen<CR>", opt, {silent = true})
map("n", "<leader>cr", "<cmd>call setqflist([])<CR>", opt)
