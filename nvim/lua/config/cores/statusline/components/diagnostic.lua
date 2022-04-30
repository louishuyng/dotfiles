local colors = require 'ui.main_colors'
local lsp = require "feline.providers.lsp"
local lsp_severity = vim.diagnostic.severity

return {
  error = {
    provider = "diagnostic_errors",
    enabled = function()
       return lsp.diagnostics_exist(lsp_severity.ERROR)
    end,

    hl = { fg = colors.red },
    icon = "  ",
  },

  warning = {
    provider = "diagnostic_warnings",
    enabled = function()
       return lsp.diagnostics_exist(lsp_severity.WARN)
    end,
    hl = { fg = colors.yellow },
    icon = "  ",
  },

  hint = {
    provider = "diagnostic_hints",
    enabled = function()
       return lsp.diagnostics_exist(lsp_severity.HINT)
    end,
    hl = { fg = colors.grey_fg2 },
    icon = "  ",
  },

  info = {
    provider = "diagnostic_info",
    enabled = function()
       return lsp.diagnostics_exist(lsp_severity.INFO)
    end,
    hl = { fg = colors.green },
    icon = "  ",
  },
}
