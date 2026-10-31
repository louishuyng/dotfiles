-- Adapter: built-in JetBrains Islands colorscheme (config.theme.jetbrains) → semantic palette.

local M = {}

function M.setup() end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme('jetbrains')
end

function M.resolve(variant)
  local c = require('config.theme.jetbrains').colors(variant)
  local s = c.syn

  return {
    bg = c.bg,
    bg_alt = c.bg_alt,
    bg_dim = c.active_line,
    surface = c.element,
    surface_alt = c.selected,
    overlay = c.line_nr,

    text = c.fg,
    subtle = c.muted,
    muted = s.comment,

    primary = s.string,
    secondary = s.func,
    tertiary = s.keyword,

    info = c.info,
    warn = c.warn,
    error = c.error,
    success = c.ok,
    attention = s.keyword,

    info_muted = c.git_change,
    warn_muted = s.attribute,
    error_muted = c.git_delete,
    success_muted = c.git_add,

    bg_info = c.info_bg,
    bg_warn = c.warn_bg,
    bg_error = c.error_bg,
    bg_success = c.ok_bg,
  }
end

return M
