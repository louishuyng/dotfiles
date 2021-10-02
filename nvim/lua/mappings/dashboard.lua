local map = require('utils.map')

local opt = {}

map("n", "<space>fo", ":DashboardFindHistory<CR>", opt, {silent = true})
map("n", "<space>ff", ":DashboardFindFile<CR>", opt, {silent = true})
map("n", "<space>fw", ":DashboardFindWord<CR>", opt, {silent = true})
map("n", "<space>bm", ":DashboardJumpMark<CR>", opt, {silent = true})
map("n", "<space>sl", [[<Cmd> SessionLoad<CR>]], opt)
map("n", "<space>ss", [[<Cmd> SessionSave<CR>]], opt)
