local map = require 'utils.map'

local opt = {}

map("n", ",ni", ":lua require('functions.network').show_local_ip()<CR>", opt)
map("n", ",nI", ":lua require('functions.network').show_public_ip()<CR>", opt)
