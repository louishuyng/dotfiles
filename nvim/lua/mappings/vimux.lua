local map = require('utils.map').map

local opt = {}

map("n", ",vp", ":VimuxPromptCommand<CR>", opt)
map("n", ",vl", ":VimuxRunLastCommand<CR>", opt)
map("n", ",vz", ":VimuxZoomRunner<CR>", opt)
map("n", ",vi", ":VimuxInspectRunner<CR>", opt)
map("n", ",vc", ":VimuxInterruptRunner<CR>", opt)
