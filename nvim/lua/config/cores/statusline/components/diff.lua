local colors = require 'ui.main_colors'

return {
  add = {
    provider = "git_diff_added",
    hl = {fg = colors.status_line_fg, bg = colors.status_line},
    icon = " "
  },

  change = {
    provider = "git_diff_changed",
    hl = {fg = colors.status_line_fg, bg = colors.status_line},
    icon = "  "
  },

  remove = {
    provider = "git_diff_removed",
    hl = {fg = colors.status_line_fg, bg = colors.status_line},
    icon = "  "
  }
}
