local map = require 'utils.map'

local opt = {}

map("n", "<space>md", ":MarkdownPreview<CR>", opt, {silent = true})
