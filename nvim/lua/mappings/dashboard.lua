local map = require 'utils.map'

local opt = {}

map("n", "<leader>fo", ":DashboardFindHistory<CR>", opt, {silent = true})
map("n", "<leader>ff", ":DashboardFindFile<CR>", opt, {silent = true})
map("n", "<leader>fw", ":DashboardFindWord<CR>", opt, {silent = true})
map("n", "<leader>bm", ":DashboardJumpMark<CR>", opt, {silent = true})
