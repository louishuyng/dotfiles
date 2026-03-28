local M = {}

local function set_transparent()
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
end

function M.toggle()
  vim.g.transparent_enabled = not (vim.g.transparent_enabled or false)

  if vim.g.transparent_enabled then
    set_transparent()
  else
    local ok, mini_base16 = pcall(require, 'mini.base16')
    if ok and mini_base16.config then
      mini_base16.setup(mini_base16.config)
    end
    local ok, highlights = pcall(require, 'utils.highlights')
    if ok then
      highlights.apply()
    end
  end

  vim.notify('Transparency ' .. (vim.g.transparent_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
end

function M.enable()
  if not vim.g.transparent_enabled then M.toggle() end
end

function M.disable()
  if vim.g.transparent_enabled then M.toggle() end
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.g.transparent_enabled then set_transparent() end
  end,
})

return M
