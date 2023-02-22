-- Gitsign
local present, gitsigns = pcall(require, "gitsigns")
if not present then return end

local mapping = require 'mappings.source_control.gitsigns'

gitsigns.setup {
  signs = {
    add = {
      hl = 'GitSignsAdd',
      text = '┃',
      numhl = 'GitSignsAddNr',
      linehl = 'GitSignsAddLn'
    },
    change = {
      hl = 'GitSignsChange',
      text = '┃',
      numhl = 'GitSignsChangeNr',
      linehl = 'GitSignsChangeLn'
    },
    delete = {
      hl = 'GitSignsDelete',
      text = '┃',
      numhl = 'GitSignsDeleteNr',
      linehl = 'GitSignsDeleteLn'
    },
    topdelete = {
      hl = 'GitSignsDelete',
      text = '▔',
      numhl = 'GitSignsDeleteNr',
      linehl = 'GitSignsDeleteLn'
    },
    changedelete = {
      hl = 'GitSignsChange',
      text = '~',
      numhl = 'GitSignsChangeNr',
      linehl = 'GitSignsChangeLn'
    }
  },
  on_attach = mapping.gitsigns_mappings

}
require("git-worktree").setup({})
