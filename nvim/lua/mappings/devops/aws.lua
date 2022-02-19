local map = require 'utils.map'

local opt = {}

map("n", "<leader>aed", ":call VimuxRunCommand('clear; eb deploy')<CR>", opt)
