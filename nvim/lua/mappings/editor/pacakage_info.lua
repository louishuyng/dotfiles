local map = require 'utils.map'

local opt = {}

map("n", "<leader>ns", ":lua require('package-info').show()<CR>", opt, {silent = true})
map("n", "<leader>nh", ":lua require('package-info').hide()<CR>", opt, {silent = true})
map("n", "<leader>nu", ":lua require('package-info').update()<CR>", opt, {silent = true})
map("n", "<leader>nd", ":lua require('package-info').delete()<CR>", opt, {silent = true})
map("n", "<leader>ni", ":lua require('package-info').install()<CR>", opt, {silent = true})
map("n", "<leader>nr", ":lua require('package-info').reinstall()<CR>", opt, {silent = true})
map("n", "<leader>np", ":lua require('package-info').change_version()<CR>", opt, {silent = true})
