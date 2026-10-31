-- Adapter: folke/tokyonight.nvim → semantic palette.

local M = {}

function M.setup()
  require('tokyonight').setup({
    style = 'night',
    light_style = 'day',
    transparent = true,
  })
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme(variant == 'light' and 'tokyonight-day' or 'tokyonight-night')
end

function M.resolve(variant)
  local ok, colors = pcall(require, 'tokyonight.colors')
  if not ok then
    return nil
  end
  local p = colors.setup({ style = variant == 'light' and 'day' or 'night' })

  return {
    bg = p.bg,
    bg_alt = p.bg_dark,
    bg_dim = p.bg_dark1,
    surface = p.bg_highlight,
    surface_alt = p.bg_visual,
    overlay = p.fg_gutter,

    text = p.fg,
    subtle = p.fg_dark,
    muted = p.comment,

    primary = p.green,
    secondary = p.cyan,
    tertiary = p.magenta,

    info = p.info,
    warn = p.warning,
    error = p.error,
    success = p.green,
    attention = p.orange,

    info_muted = p.blue,
    warn_muted = p.yellow,
    error_muted = p.red,
    success_muted = p.green2,

    bg_info = p.diff.change,
    bg_warn = p.bg_highlight,
    bg_error = p.diff.delete,
    bg_success = p.diff.add,
  }
end

return M
