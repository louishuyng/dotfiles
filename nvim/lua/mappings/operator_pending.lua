local map = require 'utils.map'

local opts = { noremap = true, silent = true }

map("o", "p", "i(", opts, {silent = true})
