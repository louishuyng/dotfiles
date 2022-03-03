local colors = require 'ui.statusline_colors'

local git = {
  add = {
    provider = 'git_diff_added',
    hl = {
      fg = colors.green
    }
  },
  change = {
    provider = 'git_diff_changed',
    hl = {
      fg = colors.orange
    }
  },
  remove = {
    provider = 'git_diff_removed',
    hl = {
      fg = colors.red
    }
  }
}

return git
