-- load all plugins
require "plugins.bufferline"
require "pluginList"
require "options"

local g = vim.g

local base16 = require "base16"
base16(base16.themes["onedark"], true)


g.auto_save = true
g.nvchad_theme = "onedark"

require "mappings"
require "highlights"
require("utils").hideStuff()
