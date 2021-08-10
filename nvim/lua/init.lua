-- load all plugins
require "mappings"
require "pluginList"
require "options"
require "plugins.indent"

local g = vim.g

vim.cmd('colorscheme kolor')

g.auto_save = true
g.nvchad_theme = "onedark"
g.move_key_modifier = 'S'

require "highlights"
require("utils").hideStuff()
require("plugins.others").escape()

vim.notify = require("notify")
