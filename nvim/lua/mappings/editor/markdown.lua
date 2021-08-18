local map = require('utils.map').map

local opt = {}

map("n", "<space>md", ":MarkdownPreview<CR>", opt, {silent = true})
