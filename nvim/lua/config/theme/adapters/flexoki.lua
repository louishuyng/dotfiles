-- Adapter: kepano/flexoki-neovim → semantic palette.
-- Dark is ink (#100F0F). Light is paper (#FFFCF0).

local M = {}

function M.setup()
  require('flexoki').setup({ variant = 'auto' })
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme(variant == 'light' and 'flexoki-light' or 'flexoki-dark')

  -- flexoki has no transparent option; Normal is its only editor-canvas bg.
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
  normal.bg, normal.ctermbg = nil, nil
  vim.api.nvim_set_hl(0, 'Normal', normal)
end

function M.resolve(variant)
  local ok, palette = pcall(require, 'flexoki.palette')
  if not ok then
    return nil
  end
  local saved = vim.o.background
  vim.o.background = variant == 'light' and 'light' or 'dark'
  local p = palette.palette()
  vim.o.background = saved
  if type(p) ~= 'table' or not p.bg then
    return nil
  end

  return {
    bg = p.bg,
    bg_alt = p['bg-2'],
    bg_dim = p['bg-2'],
    surface = p.ui,
    surface_alt = p['ui-2'],
    overlay = p['ui-3'],

    text = p.tx,
    subtle = p['tx-2'],
    muted = p['tx-3'],

    -- Orange is Flexoki's function ink. Cyan and purple carry strings and numbers.
    primary = p['or'],
    secondary = p.cy,
    tertiary = p.pu,

    info = p.bl,
    warn = p.ye,
    error = p.re,
    success = p.gr,
    attention = p['or'],

    info_muted = p['bl-2'],
    warn_muted = p['ye-2'],
    error_muted = p['re-2'],
    success_muted = p['gr-2'],

    bg_info = p['ui-2'],
    bg_warn = p['ui-2'],
    bg_error = p['ui-2'],
    bg_success = p['ui-2'],
  }
end

return M
