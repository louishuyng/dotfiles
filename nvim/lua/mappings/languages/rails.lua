local map = require 'utils.map'

local opt = {}

map("n", "<leader>ec", ":Econtroller ", opt)
map("n", "<leader>ee", ":Eenvironment ", opt)
map("n", "<leader>ej", ":Ejob ", opt)
map("n", "<leader>em", ":Emodel ", opt)
map("n", "<leader>ep", ":Epolicy ", opt)
map("n", "<leader>er", ":Eresource ", opt)
map("n", "<leader>ed", ":Eschema ", opt)
map("n", "<leader>ev", ":Eservice ", opt)
map("n", "<leader>eh", ":Ehelper ", opt)
map("n", "<leader>es", ":Espec ", opt)
map("n", "<leader>et", ":Etask ", opt)

map("n", "<leader>eg", ":Generate ", opt)
