local colors = require 'ui.main_colors'

return {
  add = {
    provider = "git_diff_added",
    hl = {fg = colors.grey_fg2, bg = colors.black3},
    icon = " "
  },

  change = {
    provider = "git_diff_changed",
    hl = {fg = colors.grey_fg2, bg = colors.black3},
    icon = "  "
  },

  remove = {
    provider = "git_diff_removed",
    hl = {fg = colors.grey_fg2, bg = colors.black3},
    icon = "  "
  }
}
