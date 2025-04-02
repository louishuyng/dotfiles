local icons = require('config.libs.icons')

-- Highlight line numbers for diagnostics
local signs = {
  Error = icons.diagnostics.Error,
  Warn = icons.diagnostics.Warn,
  Hint = icons.diagnostics.Hint,
  Info = icons.diagnostics.Info,
}

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
