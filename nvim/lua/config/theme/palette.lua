-- Theme-agnostic semantic palette.
--
-- Consumers (statusline, snacks, cmp, ...) depend on this module instead of any
-- specific colorscheme. Each consumer reads `M.colors.<role>` and registers a
-- callback via `M.on_change` so it re-applies its highlights after a theme or
-- dark/light flip.
--
-- An adapter (config.theme.adapters.<name>) is responsible for translating its
-- theme's native palette into the semantic role table this module exposes.

local M = {}

M.colors = {}
M._adapter = nil
M._subscribers = {}

local function replace_colors(fresh)
  for k in pairs(M.colors) do
    M.colors[k] = nil
  end
  for k, v in pairs(fresh or {}) do
    M.colors[k] = v
  end
end

function M.set_adapter(adapter)
  M._adapter = adapter
end

function M.rebuild()
  if not M._adapter then
    return
  end
  local variant = vim.o.background == 'light' and 'light' or 'dark'
  replace_colors(M._adapter.resolve(variant))
  for _, fn in ipairs(M._subscribers) do
    pcall(fn, M.colors)
  end
end

function M.on_change(fn)
  table.insert(M._subscribers, fn)
  if next(M.colors) then
    pcall(fn, M.colors)
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('ConfigPaletteRebuild', { clear = true }),
  callback = function()
    M.rebuild()
  end,
})

return M
