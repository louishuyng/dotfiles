-- Transparency toggle utility
local M = {}

function M.toggle()
  -- Toggle the transparency state
  vim.g.transparent_enabled = not (vim.g.transparent_enabled or false)

  if vim.g.transparent_enabled then
    -- Only make Normal background transparent
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
  else
    -- Reload colorscheme to restore normal backgrounds
    local current_colorscheme = vim.g.colors_name or 'catppuccin'
    vim.cmd.colorscheme(current_colorscheme)
  end

  local status = vim.g.transparent_enabled and 'enabled' or 'disabled'
  vim.notify('Transparency ' .. status, vim.log.levels.INFO)
end

function M.enable()
  if not vim.g.transparent_enabled then
    M.toggle()
  end
end

function M.disable()
  if vim.g.transparent_enabled then
    M.toggle()
  end
end

local function apply_transparency()
  if vim.g.transparent_enabled then
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
  end
end

-- Apply transparency after colorscheme loads
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = apply_transparency,
})

-- Apply on startup after everything loads
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.defer_fn(apply_transparency, 10)
  end,
})

return M
