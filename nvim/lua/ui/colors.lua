local M = {}

-- Get colors based on current theme
function M.get()
  -- Determine which palette to use based on theme
  local palette_name = vim.g.theme == 'light' and 'astrolight' or 'astrodark'

  -- Load the astrotheme palette
  local palette = require('astrotheme.palettes.' .. palette_name)

  return {
    -- UI Colors
    bg = palette.ui.base,
    bg_lighter = palette.ui.inactive_base or palette.ui.base,
    bg_selection = palette.ui.selection,
    border = palette.ui.border,

    -- Text Colors
    fg = palette.ui.text,
    fg_active = palette.ui.text_active or palette.ui.text,
    fg_inactive = palette.ui.text_inactive or palette.ui.text,

    -- Syntax Colors
    red = palette.syntax.red,
    orange = palette.syntax.orange,
    yellow = palette.syntax.yellow,
    green = palette.syntax.green,
    cyan = palette.syntax.cyan,
    blue = palette.syntax.blue,
    purple = palette.syntax.purple,

    -- UI Accent Colors
    ui_red = palette.ui.red,
    ui_orange = palette.ui.orange,
    ui_yellow = palette.ui.yellow,
    ui_green = palette.ui.green,
    ui_cyan = palette.ui.cyan,
    ui_blue = palette.ui.blue,
    ui_purple = palette.ui.purple,
    accent = palette.ui.accent,

    -- Additional
    comment = palette.syntax.comment,
    mute = palette.syntax.mute,
  }
end

return M
