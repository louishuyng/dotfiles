local map = require('utils.map')

local opt = {}

map("n", "<space>/", ":CommentToggle<CR>", opt)
map("v", "<space>/", ":CommentToggle<CR>", opt)
