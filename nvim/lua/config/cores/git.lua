local present, gitsigns = pcall(require, "gitsigns")
if not present then
  return
end

local mapping = require 'mappings.git'

gitsigns.setup{
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  on_attach = mapping.gitsigns_mappings
}

-- Git Messenger
vim.g.git_messenger_always_into_popup = true
vim.g.git_messenger_include_diff = "current"

-- Git Linker
local present, gitlinker = pcall(require, "gitlinker")
if not present then
  return
end

gitlinker.setup({})
