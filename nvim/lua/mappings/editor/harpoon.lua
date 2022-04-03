local map = require 'utils.map'

local opt = {}

map("n", ",mf", ":lua require(\"harpoon.mark\").add_file()<CR>", opt)
map("n", "<leader>mf", ":lua require(\"harpoon.ui\").toggle_quick_menu()<CR>", opt)
