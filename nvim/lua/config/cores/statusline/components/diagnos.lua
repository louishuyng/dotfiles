local diagnostic = vim.diagnostic

local colors = require 'ui.statusline_colors'

local lsp = require 'feline.providers.lsp'

local lsp_get_diag = function(str)
  local count = vim.tbl_count(diagnostic.get(0, { severity = str }))
  return (count > 0) and ' '..count..' ' or ''
end

local diagnos = {
  err = {
    -- provider = 'diagnostic_errors',
    provider = function()
        return '' .. lsp_get_diag("Error")
    end,
    -- left_sep = ' ',
    enabled = function() return lsp.diagnostics_exist('Error') end,
    hl = {
        fg = colors.red
    }
  },
  warn = {
    -- provider = 'diagnostic_warnings',
    provider = function()
      return '' ..  lsp_get_diag("Warn")
    end,
    -- left_sep = ' ',
    enabled = function() return lsp.diagnostics_exist('Warn') end,
    hl = {
      fg = colors.yellow
    }
  },
  info = {
    -- provider = 'diagnostic_info',
    provider = function()
      return '' .. lsp_get_diag("Info")
    end,
    -- left_sep = ' ',
    enabled = function() return lsp.diagnostics_exist('Info') end,
    hl = {
      fg = colors.blue
    }
  },
  hint = {
    -- provider = 'diagnostic_hints',
    provider = function()
      return '' .. lsp_get_diag("Hint")
    end,
    -- left_sep = ' ',
    enabled = function() return lsp.diagnostics_exist('Hint') end,
    hl = {
      fg = colors.cyan
    }
  },
}

return diagnos
