-- load all plugins
require "plugins.bufferline"
require "pluginList"
require "options"

local g = vim.g

vim.cmd('colorscheme edge')

g.auto_save = true
g.nvchad_theme = "onedark"

require "mappings"

require("utils").hideStuff()
