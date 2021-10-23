local map = require 'utils.map'

local opt = {}

map("n", ",vp", ":VimuxPromptCommand<CR>", opt, {silent = true})
map("n", ",vd", ":VimuxCloseRunner<CR>", opt, {silent = true})
map("n", ",vc", ":VimuxInterruptRunner<CR>", opt, {silent = true})
map("n", ",vl", ":VimuxRunLastCommand<CR>", opt, {silent = true})
