local merge = require 'utils.merge'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--single-branch",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

local cmp_plugins = require 'packages.cmp'
local git_plugins = require 'packages.git'
local lang_plugins = require 'packages.lang'
local navigator_plugins = require 'packages.navigator'
local testing_plugins = require 'packages.testing'
local ui_plugins = require 'packages.ui'
local utils_plugins = require 'packages.utils'
local workflow_plugins = require 'packages.workflow'

local plugins = merge(cmp_plugins, git_plugins, lang_plugins, navigator_plugins,
                      testing_plugins, ui_plugins, utils_plugins,
                      workflow_plugins)

require("lazy").setup(plugins)
