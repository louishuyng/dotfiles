local map = require('utils.map').map

local opt = {}

map("n", "w", "<Plug>WordMotion_w", opt, {silent = true})
map("n", "e", "<Plug>WordMotion_e", opt, {silent = true})
map("n", "b", "<Plug>WordMotion_b", opt, {silent = true})
map("n", "gE", "<Plug>WordMotion_gE", opt, {silent = true})
