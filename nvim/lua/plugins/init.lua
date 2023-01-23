local merge = require 'utils.merge'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--single-branch",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

local cmp_plugins = require 'plugins.cmp'
local git_plugins = require 'plugins.git'
local lang_plugins = require 'plugins.lang'
local navigator_plugins = require 'plugins.navigator'
local testing_plugins = require 'plugins.testing'
local ui_plugins = require 'plugins.ui'
local utils_plugins = require 'plugins.utils'

local plugins = merge(cmp_plugins, git_plugins, lang_plugins, navigator_plugins,
                      testing_plugins, ui_plugins, utils_plugins)

require("lazy").setup(plugins)
