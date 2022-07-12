local on_attach = require 'config/lsp/on_attach'

require("flutter-tools").setup {
  decorations = {statusline = {app_version = true, device = true}},
  widget_guides = {enabled = true},
  closing_tags = {
    highlight = "ErrorMsg", -- highlight for the closing tag
    prefix = ">", -- character to use for close tag e.g. > Widget
    enabled = true -- set to false to disable
  },
  dev_log = {
    enabled = true,
    open_cmd = "tabedit" -- command to use to open the log buffer
  },
  outline = {
    open_cmd = "topleft 30vnew", -- command to use to open the outline buffer
    auto_open = false
  },
  lsp = {on_attach = on_attach}
}
