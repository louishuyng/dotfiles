local map = require('utils.map').map

local opt = {}

map("n", ",t", ":call RunCurrentSpecFile()<CR>", opt)
map("n", ",s", ":call RunNearestSpec()<CR>", opt)
map("n", ",l", ":call RunLastSpec()<CR>", opt)
map("n", ",a", ":call RunAllSpecs()<CR>", opt)
