local icons = require('config.libs.icons')

-- Highlight line numbers for diagnostics
local signs = {
  Error = icons.diagnostics.Error,
  Warn = icons.diagnostics.Warn,
  Hint = icons.diagnostics.Hint,
  Info = icons.diagnostics.Info,
}

vim.diagnostic.config({
  underline = true,
  virtual_text = {
    spacing = 2,
    prefix = '●',
  },
  update_in_insert = true,
  severity_sort = true,
})

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type

  vim.diagnostic.config({
    signs = {
      text =icon,
      texthl = hl,
      numhl = hl,
    }
  })
end
