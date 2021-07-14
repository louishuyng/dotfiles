-- load all plugins
require "pluginList"
require "options"

local g = vim.g

g.auto_save = true

g.nvchad_theme = "onedark"

require "mappings"

require("utils").hideStuff()
