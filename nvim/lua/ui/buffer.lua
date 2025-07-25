local icons = require('config.libs.icons')
local bufferline = require('bufferline')

bufferline.setup {
  options = {
    mode = 'tabs',
    style_preset = {
      bufferline.style_preset.minimal,
      bufferline.style_preset.no_italic,
      bufferline.style_preset.no_bold,
    },
    themable = true,
    custom_areas = {
      right = function()
        local result = {}
        local seve = vim.diagnostic.severity
        local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
        local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
        local info = #vim.diagnostic.get(0, { severity = seve.INFO })
        local hint = #vim.diagnostic.get(0, { severity = seve.HINT })

        if error ~= 0 then
          table.insert(result, { text = ' ' .. icons.diagnostics.Error .. ' ' .. error, link = 'DiagnosticError' })
        end

        if warning ~= 0 then
          table.insert(result, { text = ' ' .. icons.diagnostics.Warn .. ' ' .. warning, link = 'DiagnosticWarn' })
        end

        if hint ~= 0 then
          table.insert(result, { text = ' ' .. icons.diagnostics.Hint .. ' ' .. hint, link = 'DiagnosticHint' })
        end

        if info ~= 0 then
          table.insert(result, { text = ' ' .. icons.diagnostics.Info .. ' ' .. info, link = 'DiagnosticInfo' })
        end
        return result
      end,
    },
  },
}
