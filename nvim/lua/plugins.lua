local present, _ = pcall(require, "packer_init")
local packer

if present then
  packer = require "packer"
else
  return false
end

local use = packer.use

return packer.startup{
  function()
    use {
      "wbthomason/packer.nvim",
      event = "VimEnter"
    }
    require 'packages.cmp'
    require 'packages.git'
    require 'packages.lang'
    require 'packages.navigator'
    require 'packages.org'
    require 'packages.others'
    require 'packages.ui'
    require 'packages.utils'

    require 'config'
  end,
  config = {
    compile_path = vim.fn.stdpath('config')..'/plugin/packer_compiled.lua',
    display = {
      open_fn = function()
        return require("packer.util").float({border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}})
      end,
      working_sym = "",
      error_sym = "",
      done_sym = "",
      moved_sym = ""
    }
  }
}
