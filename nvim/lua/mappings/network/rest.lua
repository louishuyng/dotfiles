local map = require 'utils.map'

local opt = {}

map("n", "<leader>re", "<Plug>RestNvim", opt)
map("n", "<leader>rl", "<Plug>RestNvimLast", opt)
