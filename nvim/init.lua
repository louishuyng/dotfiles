-- Enable Lua loader for ~30% startup improvement (nvim 0.12)
vim.loader.enable()

-- Disable unused built-in plugins
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1
vim.g.loaded_zipPlugin = 1

-- Leader keys (must be set before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Plugin Configuration
require('config')

-- Key Bindings
require('mappings')

-- Auto Setup
require('cmds')

-- UI Setup
require('ui')

-- Basic Vim Options
require('options')
