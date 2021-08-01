-- load all plugins
require "mappings"
require "pluginList"
require "options"

local g = vim.g

vim.cmd('colorscheme edge')

g.auto_save = true
g.nvchad_theme = "onedark"

require "highlights"
require("utils").hideStuff()
require("plugins.others").escape()
